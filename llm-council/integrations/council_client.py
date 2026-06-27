"""council_client.py — bridge between a source .docx and the LLM Council.

For one document it: (1) extracts the text, (2) asks the Council to rewrite it
into constrained markdown, (3) returns the chairman's rewrite plus the full
transcript (stage1/stage2/stage3 + metadata) for the audit trail.

Run as a module from the llm-council project root so the relative import of the
council package works:

    python -m integrations.council_client "<source.docx>" --title "..."
"""
import argparse
import asyncio
import json
import os
import zipfile

from lxml import etree

from backend.council import run_council  # reuses the 3-stage engine

W_NS = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"


def extract_docx_text(path: str) -> str:
    """Plain-text extraction from a .docx (no python-docx dependency)."""
    with zipfile.ZipFile(path) as zf:
        xml = zf.read("word/document.xml")
    tree = etree.fromstring(xml)
    paras = []
    for p in tree.iter(f"{W_NS}p"):
        text = "".join(t.text or "" for t in p.iter(f"{W_NS}t"))
        if text.strip():
            paras.append(text.strip())
    return "\n".join(paras)


REWRITE_PROMPT = """You are a senior HSSE management-systems consultant (ISO 45001, \
ISO 14001, ISO 9001, ISO 31000). Rewrite the following DAN construction procedure into \
a professional, audit-ready document.

Requirements:
- Correct errors, remove duplication and contradictions, standardise terminology.
- Align with ISO 45001 / 14001 / 9001 and KSA regulatory practice.
- Use the standard section set where applicable: Purpose, Scope, References, \
Definitions, Responsibilities, Procedure, Records, Related Documents.
- Write in formal corporate English. Be faithful to the source's substantive \
requirements — improve structure and clarity, do not invent new obligations.

Output ONLY constrained markdown using EXACTLY these rules (no title, no cover, \
no preamble, no closing remarks):
  # Section            (top-level section)
  ## Subsection
  ### Sub-subsection
  - bullet item
  > Note: a note
  | col | col |        (markdown tables for tabular data)
  plain paragraphs separated by blank lines

DOCUMENT TITLE: {title}

SOURCE DOCUMENT:
{source}
"""


async def rewrite_document(source_path: str, title: str) -> dict:
    text = extract_docx_text(source_path)
    prompt = REWRITE_PROMPT.format(title=title, source=text)
    result = await run_council(prompt)
    chairman = result.get("stage3") or {}
    return {
        "markdown": chairman.get("content", ""),
        "transcript": result,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("source", help="path to the source .docx")
    ap.add_argument("--title", required=True)
    ap.add_argument("--out-md", required=True, help="where to write the rewrite markdown")
    ap.add_argument("--out-transcript", help="where to write the council transcript JSON")
    args = ap.parse_args()

    out = asyncio.run(rewrite_document(args.source, args.title))
    os.makedirs(os.path.dirname(args.out_md) or ".", exist_ok=True)
    with open(args.out_md, "w", encoding="utf-8") as fh:
        fh.write(out["markdown"])
    print(f"wrote rewrite -> {args.out_md} ({len(out['markdown'])} chars)")
    if args.out_transcript:
        with open(args.out_transcript, "w", encoding="utf-8") as fh:
            json.dump(out["transcript"], fh, ensure_ascii=False, indent=2)
        print(f"wrote transcript -> {args.out_transcript}")


if __name__ == "__main__":
    main()
