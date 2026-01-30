return {
  "olimorris/codecompanion.nvim",
  version = "v17.33.0", -- Keep pinned for stability
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim", -- Optional: Makes the picker look better
  },
  config = function()
    local cc = require("codecompanion")

    -- =========================================================================
    -- 1. MODEL DEFINITIONS (LATE 2025 ROSTER)
    -- =========================================================================
    local models = {
      {
        name = "Value Coder: Qwen 3 Coder",
        id = "qwen/qwen3-coder-30b-a3b-instruct",
      },
      {
        name = "Coder: Grok Code Fast 1",
        id = "x-ai/grok-code-fast-1",
      },
      {
        name = "Basic: Gemini 2.5 Flash Lite",
        id = "google/gemini-2.5-flash-lite",
      },
      {
        name = "Performance: Claude Sonnet 4.5",
        id = "anthropic/claude-sonnet-4.5",
      },
      {
        name = "Web: Perplexity / GPT Online",
        id = "openai/gpt-4o-mini:online",
      },
    }

    -- =========================================================================
    -- 2. STATE MANAGEMENT (Persist Choice to Disk)
    -- =========================================================================
    local saved_model_path = vim.fn.stdpath("data") .. "/codecompanion_model.txt"
    local current_model = models[1].id -- Default to Qwen

    -- Load saved model if exists
    if vim.fn.filereadable(saved_model_path) == 1 then
      local saved = vim.fn.readfile(saved_model_path)[1]
      -- Verify the saved model actually exists in our list
      for _, m in ipairs(models) do
        if m.id == saved then
          current_model = saved
          break
        end
      end
    end

    -- Function to switch model
    local function set_model(model_id)
      current_model = model_id
      vim.fn.writefile({ model_id }, saved_model_path)
      vim.notify("🤖 CodeCompanion: Switched to " .. model_id)
    end

    -- Create User Command :CCModel
    vim.api.nvim_create_user_command("CCModel", function()
      local items = {}
      for _, m in ipairs(models) do
        table.insert(items, m.name)
      end
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
    -- 3. REASONING HANDLER (Essential for Sonnet 4.5 / Gemini 2.5)
    -- =========================================================================
    local function reasoning_handler(self, data)
      local extra = data.extra
      if extra and extra.reasoning then
        data.output.reasoning = { content = extra.reasoning }
        if data.output.content == "" then
          data.output.content = nil
        end
      end
      return data
    end

    -- =========================================================================
    -- 4. SETUP
    -- =========================================================================
    cc.setup({
      strategies = {
        chat = {
          adapter = "openrouter",
          keymaps = {
            submit = {
              modes = { n = "<CR>" },
              callback = function(chat)
                -- INJECTION: Force the selected model right before submit
                chat:apply_model(current_model)
                chat:submit()
              end,
            },
          },
          roles = {
            -- Update the Chat UI header to show the active model
            llm = function(adapter)
              return "🤖 " .. current_model:gsub(".*/", "")
            end,
          },
        },
        inline = {
          adapter = "openrouter",
        },
      },
      adapters = {
        openrouter = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "openrouter",
            env = {
              -- Ensure you run 'load-keys' before starting nvim!
              api_key = os.getenv("OPENROUTER_API_KEY"),
              url = "https://openrouter.ai/api",
              chat_url = "/v1/chat/completions",
            },
            schema = {
              model = {
                -- This initializes the buffer, but the submit callback overrides it
                default = current_model,
              },
            },
            handlers = { parse_message_meta = reasoning_handler },
          })
        end,
      },
    })
  end,
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat" },
    { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to AI Chat" },
    -- New Keybinding to Switch Models
    { "<leader>cm", "<cmd>CCModel<cr>", desc = "Switch AI Model" },
  },
}
