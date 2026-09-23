-- Personal keybinding overrides. Loaded after Omarchy's defaults, so unbind
-- before replacing a default, then bind your own.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-------------------------------------------------------------------------------
-- Vim-motion focus and swap (SUPER + H/J/K/L)
-------------------------------------------------------------------------------

-- Unbind conflicting defaults first.
hl.unbind("SUPER + K") -- was: Keybindings menu
hl.unbind("SUPER + J") -- was: Toggle window split
hl.unbind("SUPER + L") -- was: Toggle workspace layout

-- Move window focus with SUPER + h/j/k/l.
o.bind("SUPER + H", "Move window focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Move window focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + K", "Move window focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + J", "Move window focus down", hl.dsp.focus({ direction = "d" }))

-- Swap active window with the one next to it (SUPER + SHIFT + h/j/k/l).
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-------------------------------------------------------------------------------
-- Tiling overrides
-------------------------------------------------------------------------------
hl.unbind("SUPER + F") -- was: Full screen
hl.unbind("SUPER + ALT + F") -- was: Full width

o.bind("SUPER + D", "Toggle split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" })) -- old "fullscreen, 1"
o.bind("SUPER + ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- old "fullscreen, 0"

-------------------------------------------------------------------------------
-- Close / minimize
-------------------------------------------------------------------------------
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + SHIFT + Q", "Close all in workspace", "hypr-close-workspace")
-- Hide the active special workspace and re-activate the regular workspace
-- underneath (on this build the compositor doesn't reliably refocus it).
o.bind("SUPER + M", "Minimize special workspace", function()
  local special = hl.get_active_special_workspace()
  if not special then return end
  local underlying = hl.get_active_workspace()
  hl.dispatch(hl.dsp.workspace.toggle_special(special.name))
  if underlying and not underlying.special then
    hl.dispatch(hl.dsp.focus({ workspace = tostring(underlying.id) }))
  end
end)

-------------------------------------------------------------------------------
-- Applications
-------------------------------------------------------------------------------
hl.unbind("SUPER + ALT + RETURN") -- default Tmux; replaced below
o.bind("SUPER + ALT + RETURN", "Tmux", 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" tmux new')

-- Replace the default terminal launcher with the raw command from the old conf.
hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Terminal", 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"')

hl.unbind("SUPER + SHIFT + F") -- default nautilus file manager
o.bind("SUPER + SHIFT + F", "File manager", 'omarchy-launch-tui "yazi"')

hl.unbind("SUPER + ALT + SHIFT + F") -- default nautilus (cwd)
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", 'uwsm-app -- xdg-terminal-exec --working-directory="$(omarchy-cmd-terminal-cwd)" -e yazi')

hl.unbind("SUPER + SHIFT + B") -- default browser
o.bind("SUPER + SHIFT + B", "Browser", 'flatpak run app.zen_browser.zen')

hl.unbind("SUPER + SHIFT + ALT + B") -- default browser (private)
o.bind("SUPER + ALT + SHIFT + B", "Browser (private)", 'flatpak run app.zen_browser.zen --private')

hl.unbind("SUPER + SHIFT + N") -- default Editor (same command; avoids double-fire)
o.bind("SUPER + SHIFT + N", "Editor", 'omarchy-launch-editor')
o.bind("SUPER + SHIFT + T", "Activity", 'omarchy-launch-tui btop')
hl.unbind("SUPER + SHIFT + D") -- default Docker TUI
o.bind("SUPER + SHIFT + D", "Docker", 'omarchy-launch-tui lazydocker')
o.bind("SUPER + SHIFT + CTRL + M", "Signal", 'omarchy-launch-or-focus signal "uwsm-app -- signal-desktop"')

hl.unbind("SUPER + SHIFT + O") -- default Obsidian launcher
o.bind("SUPER + SHIFT + O", "Obsidian", 'omarchy-launch-or-focus "^obsidian$" "uwsm-app -- obsidian --enable-wayland-ime"')

hl.unbind("SUPER + SHIFT + SLASH") -- default Passwords (1password)
o.bind("SUPER + SHIFT + SLASH", "Passwords", 'uwsm-app -- 1password')

-------------------------------------------------------------------------------
-- Special workspace entry binds
-------------------------------------------------------------------------------
hl.unbind("SUPER + SHIFT + RETURN") -- was: Browser; repurposed below
-- Launch the herdr IDE session (full-screen TUI) in Ghostty.
o.bind("SUPER + SHIFT + RETURN", "IDE (herdr)", 'ghostty -e /home/equildev/.config/herdr/ide.sh')
-- Pick an existing herdr IDE workspace (walker menu) and attach to it.
o.bind("SUPER + SHIFT + I", "IDE picker (herdr)", '/home/equildev/.config/herdr/ide-picker.sh')
hl.unbind("SUPER + CTRL + RETURN") -- was: Herdr default
-- Temporary terminal on a special workspace.
o.bind("SUPER + CTRL + RETURN", "Temporary terminal", hl.dsp.workspace.toggle_special("tempterm"))

-------------------------------------------------------------------------------
-- Special workspaces submap (SUPER + S)
-------------------------------------------------------------------------------
hl.unbind("SUPER + S") -- was: Toggle scratchpad
o.bind("SUPER + S", "Activate special workspaces submap", hl.dsp.submap("specialworkspaces"))

hl.define_submap("specialworkspaces", "reset", function()
  -- Each key launches the app if not running, tags the window where
  -- applicable, then toggles its special workspace; "reset" auto-exits.
  -- Audible
  o.bind("B", "Audible", 'hyprctl clients -j | rg -q "special:audible" || omarchy-launch-webapp "https://audible.com"')
  hl.bind("B", hl.dsp.window.tag({ tag = "audible" }))
  hl.bind("B", hl.dsp.workspace.toggle_special("audible"))

  -- Gemini quick chat
  o.bind("G", "Gemini", 'hyprctl clients -j | rg -q "special:gemini" || gtk-launch Gemini')
  hl.bind("G", hl.dsp.window.tag({ tag = "quickchatgemini" }))
  hl.bind("G", hl.dsp.workspace.toggle_special("gemini"))

  -- Google Messages
  o.bind("M", "Google Messages", 'hyprctl clients -j | rg -q "special:googlemessages" || omarchy-launch-webapp "https://messages.google.com/web/conversations"')
  hl.bind("M", hl.dsp.workspace.toggle_special("googlemessages"))

  -- Nvim quick
  o.bind("N", "Nvim", hl.dsp.workspace.toggle_special("nvim"))

  -- Opencode chat
  o.bind("O", "Opencode Chat", hl.dsp.workspace.toggle_special("opencodechat"))

  -- Hermes chat
  o.bind("H", "Hermes Chat", hl.dsp.workspace.toggle_special("hermes"))

  -- Perplexity quick chat
  o.bind("A", "Perplexity (Background)", 'hyprctl clients -j | rg -q "special:aichat" || omarchy-launch-webapp "https://perplexity.ai"')
  hl.bind("A", hl.dsp.window.tag({ tag = "quickchat" }))
  hl.bind("A", hl.dsp.workspace.toggle_special("aichat"))

  -- Recall
  o.bind("R", "Recall", 'hyprctl clients -j | rg -q "chrome-app.recall" || omarchy-launch-webapp "https://app.recall.it/items"')
  hl.bind("R", hl.dsp.workspace.toggle_special("recall"))

  -- Spotify
  o.bind("S", "Spotify", 'pgrep -x spotify || spotify')
  hl.bind("S", hl.dsp.workspace.toggle_special("music"))

  -- Test browser
  o.bind("D", "Test Browser", 'hyprctl clients -j | rg -q "special:testbrowser" || uwsm-app -- chromium')
  hl.bind("D", hl.dsp.window.tag({ tag = "testbrowser" }))
  hl.bind("D", hl.dsp.workspace.toggle_special("testbrowser"))

  -- TickTick
  o.bind("T", "TickTick", 'hyprctl clients -j | rg -q "chrome-ticktick" || omarchy-launch-webapp "https://ticktick.com"')
  hl.bind("T", hl.dsp.workspace.toggle_special("ticktick"))

  -- Exit on esc or unbound key press.
  hl.bind("ESCAPE", hl.dsp.submap("reset"))
  hl.bind("catchall", hl.dsp.submap("reset"))
end)

-------------------------------------------------------------------------------
-- Web apps
-------------------------------------------------------------------------------
hl.unbind("SUPER + SHIFT + A") -- was: ChatGPT
o.bind("SUPER + SHIFT + A", "Perplexity", 'omarchy-launch-webapp "https://perplexity.ai"')
hl.unbind("SUPER + SHIFT + C") -- default Calendar webapp
o.bind("SUPER + SHIFT + C", "Calendar", 'omarchy-launch-webapp "https://app.hey.com/calendar/weeks/"')
hl.unbind("SUPER + SHIFT + E") -- default Email webapp
o.bind("SUPER + SHIFT + E", "Email", 'omarchy-launch-webapp "https://app.hey.com"')
hl.unbind("SUPER + SHIFT + Y") -- default YouTube webapp
o.bind("SUPER + SHIFT + Y", "YouTube", 'omarchy-launch-webapp "https://youtube.com/"')
o.bind("SUPER + SHIFT + ALT + M", "WhatsApp", 'omarchy-launch-or-focus-webapp WhatsApp "https://web.whatsapp.com/"')
hl.unbind("SUPER + SHIFT + P") -- default Google Photos webapp
o.bind("SUPER + SHIFT + P", "Google Photos", 'omarchy-launch-or-focus-webapp "Google Photos" "https://photos.google.com/"')

-------------------------------------------------------------------------------
-- Group mode submap (SUPER + G)
-------------------------------------------------------------------------------
hl.unbind("SUPER + G") -- was: Toggle window grouping
o.bind("SUPER + G", "Activate group mode submap", hl.dsp.submap("groupmode"))

hl.define_submap("groupmode", "reset", function()
  -- Toggle group mode with groupmode + G.
  o.bind("G", "Toggle window grouping", hl.dsp.group.toggle())
  -- Move out of group with groupmode + U.
  o.bind("U", "Move active window out of group", hl.dsp.window.move({ out_of_group = true }))
  -- Navigate groups with groupmode + N,P.
  o.bind("N", "Next window in group", hl.dsp.group.next())
  o.bind("P", "Previous window in group", hl.dsp.group.prev())
  -- Join groups with groupmode + H,J,K,L.
  o.bind("H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
  o.bind("L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))
  o.bind("K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
  o.bind("J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))
  -- Exit on esc or unbound key press.
  hl.bind("ESCAPE", hl.dsp.submap("reset"))
  hl.bind("catchall", hl.dsp.submap("reset"))
end)