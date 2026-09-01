"""FastAPI application for the LLM Council.

Run from the PROJECT ROOT (not the backend directory) so relative imports work::

    python -m backend.main

Backend listens on port 8001.
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from .config import PORT
from .council import run_council
from . import storage

app = FastAPI(title="LLM Council")

# CORS — the Vite dev server (5173) and a common alt (3000).
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class MessageRequest(BaseModel):
    content: str


@app.get("/api/health")
async def health() -> dict:
    return {"status": "ok"}


@app.get("/api/conversations")
async def get_conversations() -> list[dict]:
    return storage.list_conversations()


@app.post("/api/conversations")
async def create_conversation() -> dict:
    return storage.create_conversation()


@app.get("/api/conversations/{conversation_id}")
async def get_conversation(conversation_id: str) -> dict:
    conv = storage.get_conversation(conversation_id)
    if conv is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return conv


@app.post("/api/conversations/{conversation_id}/message")
async def post_message(conversation_id: str, req: MessageRequest) -> dict:
    """Run the council for a user message and return all stages + metadata.

    Metadata (label_to_model, aggregate_rankings) is returned here but NOT
    persisted to storage.
    """
    if storage.get_conversation(conversation_id) is None:
        raise HTTPException(status_code=404, detail="Conversation not found")

    storage.add_user_message(conversation_id, req.content)

    result = await run_council(req.content)
    if result.get("error"):
        raise HTTPException(status_code=502, detail=result["error"])

    storage.add_assistant_message(
        conversation_id, result["stage1"], result["stage2"], result["stage3"]
    )

    return {
        "stage1": result["stage1"],
        "stage2": result["stage2"],
        "stage3": result["stage3"],
        "metadata": result["metadata"],
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("backend.main:app", host="0.0.0.0", port=PORT, reload=True)
