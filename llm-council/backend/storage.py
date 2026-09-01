"""JSON-file conversation storage under ``data/conversations/``.

Each conversation is a single JSON file::

    {"id": "...", "created_at": "...", "messages": [...]}

Assistant messages store ``{role, stage1, stage2, stage3}``. Metadata
(label_to_model, aggregate_rankings) is intentionally NOT persisted — it is
ephemeral and only returned via the API.
"""
import json
import os
import uuid
from datetime import datetime, timezone

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "conversations")


def _ensure_dir() -> None:
    os.makedirs(DATA_DIR, exist_ok=True)


def _path(conversation_id: str) -> str:
    return os.path.join(DATA_DIR, f"{conversation_id}.json")


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def create_conversation() -> dict:
    _ensure_dir()
    conversation = {
        "id": uuid.uuid4().hex,
        "created_at": _now(),
        "messages": [],
    }
    _write(conversation)
    return conversation


def _write(conversation: dict) -> None:
    _ensure_dir()
    with open(_path(conversation["id"]), "w", encoding="utf-8") as fh:
        json.dump(conversation, fh, ensure_ascii=False, indent=2)


def get_conversation(conversation_id: str) -> dict | None:
    try:
        with open(_path(conversation_id), "r", encoding="utf-8") as fh:
            return json.load(fh)
    except FileNotFoundError:
        return None


def list_conversations() -> list[dict]:
    """Return lightweight summaries, newest first."""
    _ensure_dir()
    summaries: list[dict] = []
    for name in os.listdir(DATA_DIR):
        if not name.endswith(".json"):
            continue
        try:
            with open(os.path.join(DATA_DIR, name), "r", encoding="utf-8") as fh:
                conv = json.load(fh)
        except (json.JSONDecodeError, OSError):
            continue
        first_user = next(
            (m["content"] for m in conv.get("messages", []) if m.get("role") == "user"),
            "",
        )
        summaries.append(
            {
                "id": conv["id"],
                "created_at": conv.get("created_at"),
                "title": (first_user[:60] or "New conversation"),
                "message_count": len(conv.get("messages", [])),
            }
        )
    summaries.sort(key=lambda s: s.get("created_at") or "", reverse=True)
    return summaries


def add_user_message(conversation_id: str, content: str) -> dict | None:
    conv = get_conversation(conversation_id)
    if conv is None:
        return None
    conv["messages"].append({"role": "user", "content": content})
    _write(conv)
    return conv


def add_assistant_message(
    conversation_id: str, stage1: list, stage2: list, stage3: dict | None
) -> dict | None:
    """Persist the assistant turn. Metadata is deliberately excluded."""
    conv = get_conversation(conversation_id)
    if conv is None:
        return None
    conv["messages"].append(
        {
            "role": "assistant",
            "stage1": stage1,
            "stage2": stage2,
            "stage3": stage3,
        }
    )
    _write(conv)
    return conv
