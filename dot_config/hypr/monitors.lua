-- Personal monitor configuration.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Current monitors and resolutions: hyprctl monitors all

-- Laptop display: retina-style 2x scaling.
hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "auto-center-right", scale = 1.25 })

-- External monitor at 1440p 165 Hz.
hl.monitor({ output = "DP-3", mode = "2560x1440@165", position = "0x0", scale = 1, cm = "auto" })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })