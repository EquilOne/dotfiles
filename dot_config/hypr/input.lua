-- Personal input overrides, replacing Omarchy's defaults.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    kb_layout = "us",
    kb_options = "none",

    -- Change speed of keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 600,

    -- Start with numlock on by default.
    numlock_by_default = true,

    touchpad = {
      -- Use natural (inverse) scrolling.
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner.
      clickfinger_behavior = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.4,
    },
  },
})

-- Mouse cursor theme and size.
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "28")
hl.env("XCURSOR_THEME", "BreezeX-RosePine-Linux")
hl.env("XCURSOR_SIZE", "28")

-- Scroll nicely in the terminal.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_mouse = 5 })
o.window("(Alacritty|kitty)", { scroll_mouse = 2.5 })

-- Scroll nicely in opencode.
o.window({ title = "(?i).*(opencode|oc \\|).*" }, { tag = "opencode" })
o.window({ tag = "opencode" }, { scroll_mouse = 0.1 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Per-device sensitivity tweaks.
hl.device({ name = "surface-arc-mouse", sensitivity = -1.0, scroll_factor = 1.2 })
hl.device({ name = "logitech-mx-master-3s", sensitivity = -0.7, scroll_factor = 1.0 })