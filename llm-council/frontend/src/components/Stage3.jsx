import ReactMarkdown from "react-markdown";
import "./Stages.css";

// Final synthesized answer from the chairman, highlighted green.
export default function Stage3({ stage3 }) {
  if (!stage3) return null;
  return (
    <section className="stage stage3">
      <h3 className="stage-title">Stage 3 — Chairman&rsquo;s Final Answer</h3>
      <div className="stage3-box">
        <div className="markdown-content">
          <ReactMarkdown>{stage3.content || ""}</ReactMarkdown>
        </div>
        <div className="chairman-tag">Synthesized by {stage3.model}</div>
      </div>
    </section>
  );
}
