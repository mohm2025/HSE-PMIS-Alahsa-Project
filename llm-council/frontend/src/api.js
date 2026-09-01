// API client for the LLM Council backend.
// Backend runs on port 8001 (see backend/config.py). Update here if changed.
const BASE_URL = "http://localhost:8001/api";

async function request(path, options = {}) {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  if (!res.ok) {
    let detail = res.statusText;
    try {
      detail = (await res.json()).detail || detail;
    } catch {
      /* ignore */
    }
    throw new Error(detail);
  }
  return res.json();
}

export const listConversations = () => request("/conversations");

export const createConversation = () =>
  request("/conversations", { method: "POST" });

export const getConversation = (id) => request(`/conversations/${id}`);

export const sendMessage = (id, content) =>
  request(`/conversations/${id}/message`, {
    method: "POST",
    body: JSON.stringify({ content }),
  });
