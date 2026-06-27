"""Core 3-stage council deliberation logic.

Stage 1: every council model answers the user question (in parallel).
Stage 2: responses are anonymized (Response A, B, ...) and each model ranks them.
Stage 3: the chairman synthesizes a final answer using all responses + rankings.

The Stage 2 anonymization is the key idea: models cannot tell which response is
whose, so they cannot play favorites.
"""
import re
import string
from typing import Optional

from .config import COUNCIL_MODELS, CHAIRMAN_MODEL
from .openrouter import query_models_parallel, query_model


# ---------------------------------------------------------------------------
# Stage 1
# ---------------------------------------------------------------------------
async def stage1_collect_responses(question: str) -> list[dict]:
    """Query all council models in parallel; return only successful responses.

    Each item: ``{"model", "content", "reasoning_details"}``.
    """
    messages = [{"role": "user", "content": question}]
    results = await query_models_parallel(COUNCIL_MODELS, messages)
    return [r for r in results if r is not None]


# ---------------------------------------------------------------------------
# Stage 2
# ---------------------------------------------------------------------------
STAGE2_PROMPT_TEMPLATE = """You are an expert evaluator. Below is a user question \
followed by several anonymized responses from different AI assistants.

USER QUESTION:
{question}

{anonymized_responses}

Evaluate the responses on accuracy, depth of insight, and helpfulness.

Instructions — follow EXACTLY:
1. First, briefly evaluate each response individually.
2. Then output a line containing only: FINAL RANKING:
3. Under it, give a numbered list from best to worst, one per line, in the form:
   1. Response X
   2. Response Y
   (use the response letters, e.g. "Response A").
4. Do not write anything after the ranking list.
"""


def _anonymize(responses: list[dict]) -> tuple[str, dict]:
    """Map responses to "Response A/B/C..." and build a de-anonymization dict."""
    label_to_model: dict[str, str] = {}
    blocks: list[str] = []
    for i, resp in enumerate(responses):
        label = f"Response {string.ascii_uppercase[i]}"
        label_to_model[label] = resp["model"]
        blocks.append(f"--- {label} ---\n{resp['content']}")
    return "\n\n".join(blocks), label_to_model


async def stage2_collect_rankings(
    question: str, responses: list[dict]
) -> tuple[list[dict], dict]:
    """Each council model ranks the anonymized responses.

    Returns ``(rankings, label_to_model)`` where each ranking is::

        {"model", "content", "parsed_ranking": ["Response C", "Response A", ...]}
    """
    anonymized, label_to_model = _anonymize(responses)
    valid_labels = list(label_to_model.keys())

    prompt = STAGE2_PROMPT_TEMPLATE.format(
        question=question, anonymized_responses=anonymized
    )
    messages = [{"role": "user", "content": prompt}]

    # The evaluating models are the same council models.
    results = await query_models_parallel(COUNCIL_MODELS, messages, temperature=0.3)

    rankings: list[dict] = []
    for model, result in zip(COUNCIL_MODELS, results):
        if result is None:
            continue
        text = result["content"]
        rankings.append(
            {
                "model": model,
                "content": text,
                "parsed_ranking": parse_ranking_from_text(text, valid_labels),
            }
        )
    return rankings, label_to_model


def parse_ranking_from_text(text: str, valid_labels: list[str]) -> list[str]:
    """Extract an ordered list of "Response X" labels from a ranking.

    Strategy:
      1. Isolate the text after the "FINAL RANKING:" header if present.
      2. Pull "Response X" tokens in order (handles "1. Response C" and plain).
      3. Fallback: scan the entire text for "Response X" patterns in order.
    De-duplicates and keeps only labels that actually exist.
    """
    label_set = set(valid_labels)

    # 1. Prefer the section after the header.
    section = text
    match = re.search(r"FINAL RANKING:?\s*(.+)$", text, re.IGNORECASE | re.DOTALL)
    if match:
        section = match.group(1)

    def extract(src: str) -> list[str]:
        found: list[str] = []
        for m in re.finditer(r"Response\s+([A-Z])", src, re.IGNORECASE):
            label = f"Response {m.group(1).upper()}"
            if label in label_set and label not in found:
                found.append(label)
        return found

    ranking = extract(section)
    if not ranking:
        # 3. Fallback over the whole text.
        ranking = extract(text)
    return ranking


def calculate_aggregate_rankings(
    rankings: list[dict], label_to_model: dict
) -> list[dict]:
    """Average each response's rank position across all peer evaluations.

    Returns a list sorted best-first::

        [{"label", "model", "average_position", "votes"}, ...]
    """
    # position sums and vote counts keyed by label
    sums: dict[str, float] = {label: 0.0 for label in label_to_model}
    votes: dict[str, int] = {label: 0 for label in label_to_model}

    for ranking in rankings:
        for index, label in enumerate(ranking["parsed_ranking"], start=1):
            if label in sums:
                sums[label] += index
                votes[label] += 1

    aggregate: list[dict] = []
    for label, model in label_to_model.items():
        v = votes[label]
        avg = (sums[label] / v) if v else float("inf")
        aggregate.append(
            {
                "label": label,
                "model": model,
                "average_position": None if v == 0 else round(avg, 2),
                "votes": v,
            }
        )

    # Sort best (lowest average) first; unranked (inf) sink to the bottom.
    aggregate.sort(
        key=lambda x: (
            x["average_position"] if x["average_position"] is not None else float("inf")
        )
    )
    return aggregate


# ---------------------------------------------------------------------------
# Stage 3
# ---------------------------------------------------------------------------
STAGE3_PROMPT_TEMPLATE = """You are the Chairman of an AI council. Several council \
members independently answered a user's question, then anonymously ranked each \
other's answers. Using all of this, produce the single best final answer.

USER QUESTION:
{question}

COUNCIL RESPONSES:
{responses}

PEER RANKINGS (aggregated, best first):
{aggregate}

Synthesize a clear, accurate, well-structured final answer. Incorporate the \
strongest points from the highest-ranked responses, correct any errors, and do \
not mention the council process or the response labels in your answer.
"""


async def stage3_synthesize_final(
    question: str,
    responses: list[dict],
    aggregate: list[dict],
) -> Optional[dict]:
    """Chairman produces the final answer from all responses + aggregate ranks."""
    responses_block = "\n\n".join(
        f"--- {string.ascii_uppercase[i]} ({r['model']}) ---\n{r['content']}"
        for i, r in enumerate(responses)
    )
    aggregate_block = "\n".join(
        f"{i}. {a['model']} "
        f"(avg position {a['average_position']}, {a['votes']} votes)"
        for i, a in enumerate(aggregate, start=1)
    )
    prompt = STAGE3_PROMPT_TEMPLATE.format(
        question=question,
        responses=responses_block,
        aggregate=aggregate_block,
    )
    messages = [{"role": "user", "content": prompt}]
    return await query_model(CHAIRMAN_MODEL, messages, temperature=0.5)


# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------
async def run_council(question: str) -> dict:
    """Run the full 3-stage flow and return stages + metadata.

    Returns::

        {
          "stage1": [...responses...],
          "stage2": [...rankings...],
          "stage3": {chairman response} | None,
          "metadata": {"label_to_model": {...}, "aggregate_rankings": [...]},
        }
    """
    stage1 = await stage1_collect_responses(question)
    if not stage1:
        # All models failed — surface a clear error.
        return {
            "stage1": [],
            "stage2": [],
            "stage3": None,
            "metadata": {"label_to_model": {}, "aggregate_rankings": []},
            "error": "All council models failed to respond.",
        }

    stage2, label_to_model = await stage2_collect_rankings(question, stage1)
    aggregate = calculate_aggregate_rankings(stage2, label_to_model)
    stage3 = await stage3_synthesize_final(question, stage1, aggregate)

    return {
        "stage1": stage1,
        "stage2": stage2,
        "stage3": stage3,
        "metadata": {
            "label_to_model": label_to_model,
            "aggregate_rankings": aggregate,
        },
    }
