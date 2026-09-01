import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Dev server on 5173 (Vite default). Backend runs separately on 8001.
export default defineConfig({
  plugins: [react()],
  server: { port: 5173 },
});
