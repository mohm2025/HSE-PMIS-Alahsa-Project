"""Thin async client over the OpenRouter chat-completions API.

Design principle: graceful degradation. A single model failure returns None and
is filtered out by the caller, rather than failing the whole request.
"""
import asyncio
from typing import Optional

import httpx

from .config import (
    OPENROUTER_API_KEY,
    OPENROUTER_BASE_URL,
    REQUEST_TIMEOUT,
    MAX_TOKENS,
    APP_TITLE,
    APP_URL,
)


def _headers() -> dict:
    return {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        # Optional but recommended OpenRouter attribution headers.
        "HTTP-Referer": APP_URL,
        "X-Title": APP_TITLE,
    }


async def query_model(
    model: str,
    messages: list[dict],
    *,
    temperature: float = 0.7,
    max_tokens: int = MAX_TOKENS,
    client: Optional[httpx.AsyncClient] = None,
) -> Optional[dict]:
    """Query a single model.

    Returns a dict ``{"model", "content", "reasoning_details"}`` on success, or
    ``None`` on any failure (network error, non-200, malformed payload). Never
    raises to the caller.
    """
    payload = {
        "model": model,
        "messages": messages,
        "temperature": temperature,
        "max_tokens": max_tokens,
    }

    owns_client = client is None
    if owns_client:
        client = httpx.AsyncClient(timeout=REQUEST_TIMEOUT)

    try:
        resp = await client.post(
            f"{OPENROUTER_BASE_URL}/chat/completions",
            headers=_headers(),
            json=payload,
        )
        resp.raise_for_status()
        data = resp.json()
        choice = data["choices"][0]
        message = choice["message"]
        return {
            "model": model,
            "content": message.get("content", "") or "",
            # Some reasoning models return a structured trace; pass it through.
            "reasoning_details": message.get("reasoning")
            or message.get("reasoning_details"),
        }
    except (httpx.HTTPError, KeyError, IndexError, ValueError) as exc:
        # Log but never propagate — the council continues with whatever succeeds.
        print(f"[openrouter] model '{model}' failed: {exc!r}")
        return None
    finally:
        if owns_client:
            await client.aclose()


async def query_models_parallel(
    models: list[str],
    messages: list[dict],
    *,
    temperature: float = 0.7,
    max_tokens: int = MAX_TOKENS,
) -> list[Optional[dict]]:
    """Query many models concurrently. Order matches ``models``.

    Failed models appear as ``None`` in the returned list (callers filter them).
    """
    async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT) as client:
        tasks = [
            query_model(
                model,
                messages,
                temperature=temperature,
                max_tokens=max_tokens,
                client=client,
            )
            for model in models
        ]
        return await asyncio.gather(*tasks)
