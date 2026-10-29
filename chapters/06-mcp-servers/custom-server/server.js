// server.js: chapter 6 (ch06:279-307), verbatim from the book. A one-tool MCP server over stdio.
// Replace https://internal-api.company.com/metrics/ with your own API: that host is the book's example.
// npm install, then: claude mcp add --transport stdio company -- node /full/path/to/server.js

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "my-custom-server", version: "1.0.0" });

server.registerTool(
  "get_company_data",
  {
    description: "Fetches internal company metrics from our API",
    inputSchema: z.object({ metric: z.string(), timeRange: z.string().optional() }),
  },
  async ({ metric, timeRange }) => {
    const response = await fetch(
      `https://internal-api.company.com/metrics/${metric}?range=${timeRange || "7d"}`
    );
    const data = await response.json();
    return { content: [{ type: "text", text: JSON.stringify(data, null, 2) }] };
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main();
