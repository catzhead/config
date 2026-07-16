-- Local-LLM copy-editing via LM Studio (OpenAI-compatible server on the Mac).
-- Lazy-loaded on command, so nvim startup is untouched on machines without
-- LM Studio; the endpoint is only contacted when you invoke an AI command.
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  opts = {
    adapters = {
      http = {
        lmstudio = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              -- LM Studio default; override per machine with $LMSTUDIO_URL
              url = os.getenv("LMSTUDIO_URL") or "http://localhost:1234",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
              api_key = "lm-studio", -- dummy; the local server ignores auth
            },
            schema = {
              model = {
                -- set $LMSTUDIO_MODEL to the id LM Studio shows at /v1/models
                default = os.getenv("LMSTUDIO_MODEL") or "set-LMSTUDIO_MODEL",
              },
            },
          })
        end,
      },
    },
    strategies = {
      chat = { adapter = "lmstudio" },
      inline = { adapter = "lmstudio" },
      cmd = { adapter = "lmstudio" },
    },
    opts = {
      -- Edit like a copy-editor, not a coder.
      system_prompt = function(_)
        return table.concat({
          "You are a careful copy-editor for long-form prose (blog posts, articles, books).",
          "Preserve the author's voice and meaning.",
          "Do not wrap output in Markdown code fences.",
          "When asked to rewrite, return ONLY the revised prose, with no commentary.",
        }, " ")
      end,
    },
  },
}
