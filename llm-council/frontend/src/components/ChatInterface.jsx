import { useState } from "react";
import "./ChatInterface.css";

// Multiline composer: Enter to send, Shift+Enter for a new line.
export default function ChatInterface({ onSend, disabled }) {
  const [text, setText] = useState("");

  function submit() {
    const trimmed = text.trim();
    if (!trimmed || disabled) return;
    onSend(trimmed);
    setText("");
  }

  function onKeyDown(e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      submit();
    }
  }

  return (
    <div className="composer">
      <textarea
        rows={3}
        value={text}
        placeholder="Ask the council… (Enter to send, Shift+Enter for new line)"
        onChange={(e) => setText(e.target.value)}
        onKeyDown={onKeyDown}
        disabled={disabled}
      />
      <button onClick={submit} disabled={disabled || !text.trim()}>
        Send
      </button>
    </div>
  );
}
