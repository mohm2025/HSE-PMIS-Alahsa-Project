"""run_all.py — drive the full Council -> branded .docx pipeline for every
document listed in manifest.json.

For each document:
  1. extract text from the source .docx,
  2. run the LLM Council (requires OPENROUTER_API_KEY),
  3. write the synthesized rewrite (build/<code>.md) and the full council
     transcript (build/<code>.council.json),
  4. render a branded .docx via render_docx.cjs.

Run from the llm-council project root:

    python -m integrations.run_all                 # all documents -> build/
    python -m integrations.run_all --apply         # also copy into the IMS folders
    python -m integrations.run_all --only GEN CEMP # subset

The repo root is assumed to be the parent of this package's parent
(…/llm-council/integrations -> repo root is two levels up).
"""
import argparse
import asyncio
import json
import os
import shutil
import subprocess

from integrations.council_client import rewrite_document

HERE = os.path.dirname(__file__)
PROJECT_ROOT = os.path.abspath(os.path.join(HERE, ".."))      # …/llm-council
REPO_ROOT = os.path.abspath(os.path.join(PROJECT_ROOT, ".."))  # repo root
BUILD = os.path.join(HERE, "build")
RENDERER = os.path.join(HERE, "render_docx.cjs")


def load_manifest() -> list[dict]:
    with open(os.path.join(HERE, "manifest.json"), encoding="utf-8") as fh:
        return json.load(fh)["documents"]


async def process(doc: dict, apply: bool) -> None:
    code = doc["code"]
    source = os.path.join(REPO_ROOT, doc["source"])
    md_path = os.path.join(BUILD, f"{code}.md")
    meta_path = os.path.join(BUILD, f"{code}.meta.json")
    transcript_path = os.path.join(BUILD, f"{code}.council.json")
    out_docx = os.path.join(BUILD, f"{doc['docno']}_R00.docx")

    print(f"\n=== {code}: {doc['title']} ===")
    print(f"  source: {source}")

    # 1-3. Council rewrite
    result = await rewrite_document(source, doc["title"])
    os.makedirs(BUILD, exist_ok=True)
    with open(md_path, "w", encoding="utf-8") as fh:
        fh.write(result["markdown"])
    with open(transcript_path, "w", encoding="utf-8") as fh:
        json.dump(result["transcript"], fh, ensure_ascii=False, indent=2)
    with open(meta_path, "w", encoding="utf-8") as fh:
        json.dump(
            {"docno": doc["docno"], "rev": "00", "title": doc["title"],
             "short": doc["short"], "manualLine": "DAN Construction Safety Manual (DCSM)"},
            fh,
        )
    print(f"  rewrite: {len(result['markdown'])} chars -> {md_path}")

    # 4. Render branded .docx (Node)
    subprocess.run(["node", RENDERER, md_path, meta_path, out_docx], check=True)

    if apply:
        dest = os.path.join(REPO_ROOT, doc["out_folder"], f"{doc['docno']}_R00.docx")
        shutil.copyfile(out_docx, dest)
        print(f"  applied -> {dest}")


async def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", nargs="*", help="subset of document codes")
    ap.add_argument("--apply", action="store_true",
                    help="copy rendered docs into the IMS folders")
    args = ap.parse_args()

    docs = load_manifest()
    if args.only:
        wanted = {c.upper() for c in args.only}
        docs = [d for d in docs if d["code"].upper() in wanted]

    os.makedirs(BUILD, exist_ok=True)
    for doc in docs:
        await process(doc, args.apply)
    print(f"\nDone. {len(docs)} document(s) in {BUILD}")


if __name__ == "__main__":
    asyncio.run(main())
