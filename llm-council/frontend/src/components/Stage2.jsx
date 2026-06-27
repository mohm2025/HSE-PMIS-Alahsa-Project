import { useState } from "react";
import ReactMarkdown from "react-markdown";
import "./Stages.css";

// Replace anonymous "Response X" labels with **Model Name** for readability.
// Models only ever saw the anonymous labels — this substitution is display-only.
function deanonymize(text, labelToModel) {
  if (!text || !labelToModel) return text || "";
  let out = text;
  for (const [label, model] of Object.entries(labelToModel)) {
    out = out.replaceAll(label, `**${model}**`);
  }
  return out;
}

function modelForLabel(label, labelToModel) {
  return (labelToModel && labelToModel[label]) || label;
}

// Stage 2: raw peer evaluations (tabbed) + extracted ranking + aggregate table.
export default function Stage2({ stage2, metadata }) {
  const [active, setActive] = useState(0);
  if (!stage2 || stage2.length === 0) return null;

  const labelToModel = metadata?.label_to_model || {};
  const aggregate = metadata?.aggregate_rankings || [];
  const current = stage2[active];

  return (
    <section className="stage stage2">
      <h3 className="stage-title">Stage 2 — Anonymized Peer Review</h3>
      <p className="stage-note">
        Each model evaluated the others as “Response A/B/C…”. Model names shown in{" "}
        <strong>bold</strong> are de-anonymized client-side for readability only —
        the evaluators saw anonymous labels.
      </p>

      <div className="tabs">
        {stage2.map((r, i) => (
          <button
            key={i}
            className={i === active ? "tab active" : "tab"}
            onClick={() => setActive(i)}
          >
            {r.model}
          </button>
        ))}
      </div>

      <div className="eval-block">
        <div className="markdown-content">
          <ReactMarkdown>
            {deanonymize(current?.content, labelToModel)}
          </ReactMarkdown>
        </div>

        <div className="extracted">
          <h4>Extracted Ranking</h4>
          {current?.parsed_ranking?.length ? (
            <ol>
              {current.parsed_ranking.map((label) => (
                <li key={label}>
                  <strong>{modelForLabel(label, labelToModel)}</strong>{" "}
                  <span className="muted">({label})</span>
                </li>
              ))}
            </ol>
          ) : (
            <p className="muted">No ranking could be parsed from this evaluation.</p>
          )}
        </div>
      </div>

      {aggregate.length > 0 && (
        <div className="aggregate">
          <h4>Aggregate Ranking</h4>
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>Model</th>
                <th>Avg. position</th>
                <th>Votes</th>
              </tr>
            </thead>
            <tbody>
              {aggregate.map((a, i) => (
                <tr key={a.label}>
                  <td>{i + 1}</td>
                  <td>{a.model}</td>
                  <td>{a.average_position ?? "—"}</td>
                  <td>{a.votes}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}
