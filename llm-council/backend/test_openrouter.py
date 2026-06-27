"""Connectivity / model-identifier check for OpenRouter.

Run from the project root::

    python -m backend.test_openrouter
    python -m backend.test_openrouter openai/gpt-5.1

Verifies non-streaming queries against each council model (or a model passed as
an argument) so identifiers can be validated before adding them to the council.
"""
import asyncio
import sys

from .config import COUNCIL_MODELS, CHAIRMAN_MODEL, OPENROUTER_API_KEY
from .openrouter import query_model


async def _check(model: str) -> None:
    print(f"→ {model} ... ", end="", flush=True)
    result = await query_model(
        model,
        [{"role": "user", "content": "Reply with exactly: pong"}],
        max_tokens=20,
    )
    if result is None:
        print("FAILED")
    else:
        snippet = result["content"].strip().replace("\n", " ")[:60]
        print(f"OK — {snippet!r}")


async def main() -> None:
    if not OPENROUTER_API_KEY:
        print("ERROR: OPENROUTER_API_KEY is not set (check your .env).")
        return

    models = sys.argv[1:] or list(dict.fromkeys(COUNCIL_MODELS + [CHAIRMAN_MODEL]))
    print(f"Testing {len(models)} model(s):\n")
    for model in models:
        await _check(model)


if __name__ == "__main__":
    asyncio.run(main())
