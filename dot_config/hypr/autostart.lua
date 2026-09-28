-- Extra autostart processes.
o.exec_on_start("walker --gapplication-service")

-- rose-pine-cursor
o.exec_on_start("hyprctl setcursor rose-pine-hyprcursor 28")

-- >>> lacquer desktop block >>>
-- Written by Lacquer: cursor theme and nightlight autostart. Safe to
-- hand-edit; Lacquer only ever rewrites what's between the fences.
hl.env("XCURSOR_THEME", "default")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "default")
hl.env("HYPRCURSOR_SIZE", "24")
o.launch_on_start("hyprsunset")
-- <<< lacquer desktop block <<<
