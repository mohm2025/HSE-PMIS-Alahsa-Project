/**
 * render_docx.cjs — render the Council's synthesized rewrite into a branded
 * DAN .docx using the shared template engine (dan_template.js).
 *
 * Usage:
 *   node render_docx.cjs <body.md> <meta.json> <out.docx>
 *
 * The Council is prompted to return a constrained markdown subset:
 *   # H1   ## H2   ### H3   - bullet   > Note: ...   | table | rows |
 * Anything else becomes a justified paragraph. This keeps output deterministic
 * and on-brand regardless of which models answered.
 */
const fs = require("fs");
const T = require("./dan_template.js");
const { makeDoc, write, H1, H2, H3, P, bullet, note, table } = T;

function stripInline(s) {
  // remove markdown emphasis / code markers; keep the text
  return s.replace(/\*\*(.+?)\*\*/g, "$1").replace(/\*(.+?)\*/g, "$1")
          .replace(/`(.+?)`/g, "$1").trim();
}

function parseMarkdown(md) {
  const lines = md.replace(/\r\n/g, "\n").split("\n");
  const body = [];
  let para = [];
  let tbl = null; // {rows: [[...]]}

  const flushPara = () => {
    if (para.length) { body.push(P(stripInline(para.join(" ")))); para = []; }
  };
  const flushTable = () => {
    if (!tbl) return;
    const rows = tbl.rows.filter(
      (r) => !r.every((c) => /^[-:\s]*$/.test(c)) // drop |---|---| separators
    );
    if (rows.length) {
      const headers = rows[0].map(stripInline);
      const dataRows = rows.slice(1).map((r) => r.map(stripInline));
      const n = headers.length || 1;
      const widths = Array(n).fill(Math.floor(9360 / n));
      widths[n - 1] += 9360 - widths.reduce((a, b) => a + b, 0);
      body.push(table(headers, widths, dataRows));
    }
    tbl = null;
  };

  for (const raw of lines) {
    const line = raw.trimEnd();
    const trimmed = line.trim();

    if (trimmed.startsWith("|") && trimmed.endsWith("|")) {
      flushPara();
      const cells = trimmed.slice(1, -1).split("|").map((c) => c.trim());
      (tbl ||= { rows: [] }).rows.push(cells);
      continue;
    }
    flushTable();

    if (trimmed === "") { flushPara(); continue; }

    let m;
    if ((m = trimmed.match(/^#\s+(.*)/)))      { flushPara(); body.push(H1(stripInline(m[1]))); }
    else if ((m = trimmed.match(/^##\s+(.*)/)))  { flushPara(); body.push(H2(stripInline(m[1]))); }
    else if ((m = trimmed.match(/^###\s+(.*)/))) { flushPara(); body.push(H3(stripInline(m[1]))); }
    else if ((m = trimmed.match(/^>\s*(?:Note:\s*)?(.*)/i))) { flushPara(); body.push(note(stripInline(m[1]))); }
    else if ((m = trimmed.match(/^[-*]\s+(.*)/))) { flushPara(); body.push(bullet(stripInline(m[1]))); }
    else { para.push(trimmed); }
  }
  flushPara();
  flushTable();
  return body;
}

function main() {
  const [, , mdPath, metaPath, outPath] = process.argv;
  if (!mdPath || !metaPath || !outPath) {
    console.error("Usage: node render_docx.cjs <body.md> <meta.json> <out.docx>");
    process.exit(1);
  }
  const md = fs.readFileSync(mdPath, "utf-8");
  const meta = JSON.parse(fs.readFileSync(metaPath, "utf-8"));
  const body = parseMarkdown(md);
  if (!body.length) { console.error("No content parsed from markdown."); process.exit(1); }

  const doc = makeDoc({
    docno: meta.docno,
    rev: meta.rev || "00",
    title: meta.title,
    short: meta.short || meta.title,
    manualLine: meta.manualLine || "DAN Construction Safety Manual (DCSM)",
    body,
  });
  return write(doc, outPath);
}

main();
