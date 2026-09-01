import { useEffect, useState } from "react";
import {
  listConversations,
  createConversation,
  getConversation,
  sendMessage,
} from "./api.js";
import ChatInterface from "./components/ChatInterface.jsx";
import Stage1 from "./components/Stage1.jsx";
import Stage2 from "./components/Stage2.jsx";
import Stage3 from "./components/Stage3.jsx";
import "./App.css";

export default function App() {
  const [conversations, setConversations] = useState([]);
  const [current, setCurrent] = useState(null); // {id, messages}
  // Metadata is held in UI state for display only; it is NOT persisted to backend.
  const [metaByIndex, setMetaByIndex] = useState({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const refreshList = () => listConversations().then(setConversations).catch(() => {});

  useEffect(() => {
    refreshList();
  }, []);

  async function openConversation(id) {
    setError(null);
    const conv = await getConversation(id);
    setCurrent(conv);
    setMetaByIndex({}); // metadata is ephemeral; not available for past turns
  }

  async function startNew() {
    setError(null);
    const conv = await createConversation();
    await refreshList();
    setCurrent(conv);
    setMetaByIndex({});
  }

  async function handleSend(text) {
    if (!current) return;
    setLoading(true);
    setError(null);

    // optimistic user message
    const optimistic = {
      ...current,
      messages: [...current.messages, { role: "user", content: text }],
    };
    setCurrent(optimistic);

    try {
      const result = await sendMessage(current.id, text);
      const assistantMsg = {
        role: "assistant",
        stage1: result.stage1,
        stage2: result.stage2,
        stage3: result.stage3,
      };
      const updated = {
        ...optimistic,
        messages: [...optimistic.messages, assistantMsg],
      };
      setCurrent(updated);
      // store metadata keyed by the assistant message index
      const idx = updated.messages.length - 1;
      setMetaByIndex((m) => ({ ...m, [idx]: result.metadata }));
      refreshList();
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="app">
      <aside className="sidebar">
        <button className="new-btn" onClick={startNew}>
          + New conversation
        </button>
        <ul className="conv-list">
          {conversations.map((c) => (
            <li
              key={c.id}
              className={current && current.id === c.id ? "active" : ""}
              onClick={() => openConversation(c.id)}
            >
              <span className="conv-title">{c.title}</span>
              <span className="conv-count">{c.message_count}</span>
            </li>
          ))}
        </ul>
      </aside>

      <main className="main">
        <header className="app-header">
          <h1>LLM Council</h1>
          <p className="subtitle">
            Multiple models answer, anonymously rank each other, and a chairman
            synthesizes the final answer.
          </p>
        </header>

        {!current && (
          <div className="empty">Start a new conversation to begin.</div>
        )}

        {current && (
          <div className="thread">
            {current.messages.map((msg, idx) =>
              msg.role === "user" ? (
                <div key={idx} className="user-msg">
                  <div className="markdown-content">{msg.content}</div>
                </div>
              ) : (
                <div key={idx} className="assistant-msg">
                  <Stage1 stage1={msg.stage1} />
                  <Stage2
                    stage2={msg.stage2}
                    metadata={metaByIndex[idx]}
                  />
                  <Stage3 stage3={msg.stage3} />
                </div>
              )
            )}
            {loading && <div className="loading">Council deliberating…</div>}
            {error && <div className="error">Error: {error}</div>}
          </div>
        )}

        {current && <ChatInterface onSend={handleSend} disabled={loading} />}
      </main>
    </div>
  );
}
