import { useState } from "react";
import ReactMarkdown from "react-markdown";
import "./Stages.css";

// Tabbed view of each council model's individual Stage 1 response.
export default function Stage1({ stage1 }) {
  const [active, setActive] = useState(0);
  if (!stage1 || stage1.length === 0) return null;

  return (
    <section className="stage stage1">
      <h3 className="stage-title">Stage 1 — Individual Responses</h3>
      <div className="tabs">
        {stage1.map((r, i) => (
          <button
            key={i}
            className={i === active ? "tab active" : "tab"}
            onClick={() => setActive(i)}
          >
            {r.model}
          </button>
        ))}
      </div>
      <div className="markdown-content">
        <ReactMarkdown>{stage1[active]?.content || ""}</ReactMarkdown>
      </div>
    </section>
  );
}
