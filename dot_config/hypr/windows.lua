-- Custom window rules.

-- AI chat special workspaces
o.window({ tag = "quickchat" }, { workspace = "special:aichat silent" })
o.window({ tag = "quickchatgemini" }, { workspace = "special:gemini silent" })

-- Audible special workspace
o.window({ tag = "audible" }, { workspace = "special:audible silent" })

-- Google Messages special workspace
o.window({ title = "^(chrome-messages.google.com__web_conversations-Default)$" }, { workspace = "special:googlemessages silent" })

-- Nvim special workspace
hl.workspace_rule({ workspace = "special:nvim", on_created_empty = "omarchy-launch-tui nvim" })

-- Opencode chat special workspace
hl.workspace_rule({
  workspace = "special:opencodechat",
  on_created_empty = 'uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.opencode -e bash -c "cd ~/.opencode-chat && ~/.local/bin/opencode"',
})

-- Hermes chat special workspace
hl.workspace_rule({
  workspace = "special:hermes",
  on_created_empty = 'uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.hermes -e bash -c "cd ~ && ~/.local/bin/hermes --tui"',
})

-- Pygame launch in dedicated workspace
o.window({ title = "(?i)pygame.?window" }, { tag = "+pygame" })
o.window({ tag = "pygame" }, { tag = "-default-opacity" })
o.window({ tag = "pygame" }, { fullscreen = true })
o.window({ tag = "pygame" }, { workspace = "10" })

-- Recall special workspace
o.window({ class = "^(chrome-app.recall.it__items-Default)$" }, { workspace = "special:recall silent" })

-- Scratchpad special workspace
hl.workspace_rule({ workspace = "special:scratchpad", on_created_empty = "uwsm-app -- xdg-terminal-exec --class=scratchterm" })

-- Tempterm special workspace
hl.workspace_rule({
  workspace = "special:tempterm",
  on_created_empty = 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" --class=tempterm',
})

-- Spotify special workspace
o.window({ class = "^(Spotify)$" }, { workspace = "special:music silent" })

-- Test browser special workspace
o.window({ tag = "testbrowser" }, { workspace = "special:testbrowser silent" })

-- TickTick special workspace
o.window({ class = "^(chrome-ticktick.com__-Default)$" }, { workspace = "special:ticktick silent" })

-- Zen fullscreen
o.window({ class = "^(app.zen_browser.zen)$" }, { maximize = true })

-- Named rules
-- BTOP
o.window(
  { initial_class = "org.omarchy.btop", title = "btop" },
  { name = "btop-size", min_size = "(monitor_w*0.6) (monitor_h*0.7)", center = true }
)

-- Jolt
o.window(
  { initial_class = "org.omarchy.jolt", initial_title = "Ghostty" },
  { name = "jolt-size", float = true, min_size = "(monitor_w*0.5) (monitor_h*0.6)", max_size = "(monitor_w*0.7) (monitor_h*0.7)", center = true }
)