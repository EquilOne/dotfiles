-- Personal look'n'feel overrides, replacing Omarchy's defaults.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#general

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 5,
  },

  decoration = {
    -- Use round window corners.
    rounding = 6,
  },
})

-- >>> lacquer managed block >>>
-- Written by Lacquer. Safe to hand-edit: Lacquer re-reads this block
-- every time it opens, and only ever rewrites what's between the fences.
hl.config({
  animations = {
    enabled = false,
  },

  decoration = {
    active_opacity = 0.9,
    border_part_of_window = false,
    dim_inactive = true,
    dim_strength = 0.1,
    fullscreen_opacity = 0.95,
    inactive_opacity = 0.85,

    blur = {
      contrast = 1,
      enabled = true,
      noise = 0.02,
      passes = 2,
      popups = false,
      size = 6,
      vibrancy = 0.25,
      xray = false,
    },
  },

  general = {
    border_size = 2,
    gaps_in = 3,

    snap = {
      enabled = true,
      monitor_gap = 11,
      window_gap = 9,
    },
  },
})
-- <<< lacquer managed block <<<
