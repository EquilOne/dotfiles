return {
  "olimorris/codecompanion.nvim",
  version = false, -- Use latest
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim", -- Optional: nicer UI pickers
  },
  config = function()
    local cc = require("codecompanion")

    -- =========================================================================
    -- 1. MODEL DEFINITIONS
    -- =========================================================================
    local models = {
      { name = "Value Coder: Qwen 3 Coder", id = "qwen/qwen3-coder-30b-a3b-instruct" },
      { name = "Coder: Grok Code Fast 1", id = "x-ai/grok-code-fast-1" },
      { name = "Basic: Gemini 2.5 Flash Lite", id = "google/gemini-2.5-flash-lite" },
      { name = "Performance: Claude Sonnet 4.5", id = "anthropic/claude-sonnet-4.5" },
      { name = "Web: Perplexity / GPT Online", id = "openai/gpt-4o-mini:online" },
    }

    -- =========================================================================
    -- 2. STATE MANAGEMENT (Persist Model Choice to Disk)
    -- =========================================================================
    local saved_model_path = vim.fn.stdpath("data") .. "/codecompanion_model.txt"
    local current_model = models[1].id

    if vim.fn.filereadable(saved_model_path) == 1 then
      local saved = vim.fn.readfile(saved_model_path)[1]
      for _, m in ipairs(models) do
        if m.id == saved then
          current_model = saved
          break
        end
      end
    end

    local function set_model(model_id)
      current_model = model_id
      vim.fn.writefile({ model_id }, saved_model_path)
      vim.notify("🤖 CodeCompanion: Switched to " .. model_id)
    end

    -- Create :CCModel user command to switch models
    vim.api.nvim_create_user_command("CCModel", function()
      local items = vim.tbl_map(function(m) return m.name end, models)
      vim.ui.select(items, { prompt = "Select AI Model:" }, function(choice)
        if choice then
          for _, m in ipairs(models) do
            if m.name == choice then
              set_model(m.id)
              break
            end
          end
        end
      end)
    end, {})

    -- =========================================================================
    -- 3. SETUP
    -- =========================================================================
    cc.setup({
      adapters = {
        -- HTTP adapter: direct access to OpenRouter models
        http = {
          openrouter = function()
            return require("codecompanion.adapters").extend("openrouter", {
              env = {
                api_key = os.getenv("OPENROUTER_API_KEY"),
              },
              schema = {
                model = {
                  default = current_model,
                },
              },
            })
          end,
        },
        -- ACP adapter: route through opencode for agentic capabilities
        acp = {
          opencode = function()
            return require("codecompanion.adapters").extend("opencode", {
              defaults = {
                timeout = 30000, -- 30s timeout for agentic tasks
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          adapter = {
            name = "openrouter",
            model = current_model,
          },
          roles = {
            llm = function(adapter)
              return "🤖 " .. current_model:gsub(".*/", "")
            end,
          },
        },
        inline = {
          adapter = "openrouter",
        },
      },
    })
  end,
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat", mode = { "n", "x" } },
    { "<leader>ax", "<cmd>CodeCompanion Actions<cr>", desc = "AI Actions", mode = { "n", "x" } },
    { "<leader>am", "<cmd>CCModel<cr>", desc = "Switch AI Model" },
    { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to AI Chat" },
    {
      "go",
      function()
        return require("codecompanion").operator()
      end,
      expr = true,
      mode = { "n", "x" },
      desc = "Add range to AI Chat",
    },
  },
}
