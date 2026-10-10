-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- This MacBook has no keyboard-backlight keys. Super plus the screen
-- brightness keys changes the keyboard light instead.
o.bind("SUPER + XF86MonBrightnessUp", "Keyboard brightness up", "omarchy-brightness-keyboard up", { locked = true, repeating = true })
o.bind("SUPER + XF86MonBrightnessDown", "Keyboard brightness down", "omarchy-brightness-keyboard down", { locked = true, repeating = true })

-- F6 is the crescent-moon / DND key. The firmware reports it as XF86Sleep,
-- and logind would suspend. suspend-key-dnd-inhibit.service blocks that
-- handle so this bind can toggle notification silencing instead.
o.bind_toggle("XF86Sleep", "Toggle Do Not Disturb", "notification-silencing", { locked = true })

-- F3 is Show Desktop / Mission Control. With fnmode=1 the firmware
-- reports KEY_SCALE (XF86LaunchA); Fn+F3 is F3. SUPER+S stays bound.
o.bind("XF86LaunchA", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("F3", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))

-- Lid display switching is handled by clamshell-lid-inhibit (logind LidClosed).
-- The SMC switch bind races with lid-open and can leave eDP-1 disabled.
hl.unbind("switch:on:Lid Switch")
hl.unbind("switch:off:Lid Switch")
hl.unbind("switch:on:Apple SMC power/lid events")
hl.unbind("switch:off:Apple SMC power/lid events")

-- LG UltraFine brightness is USB HID, not DDC. Route the stock brightness
-- keys through a local wrapper that talks to the panel when it is focused.
local brightness_display = os.getenv("HOME") .. "/.local/bin/omarchy-brightness-display"
hl.unbind("XF86MonBrightnessUp")
hl.unbind("XF86MonBrightnessDown")
hl.unbind("SHIFT + XF86MonBrightnessUp")
hl.unbind("SHIFT + XF86MonBrightnessDown")
hl.unbind("ALT + XF86MonBrightnessUp")
hl.unbind("ALT + XF86MonBrightnessDown")
o.bind("XF86MonBrightnessUp", "Brightness up", brightness_display .. " +5%", { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", brightness_display .. " 5%-", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessUp", "Brightness maximum", brightness_display .. " 100%", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessDown", "Brightness minimum", brightness_display .. " 1%", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessUp", "Brightness up precise", brightness_display .. " +1%", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessDown", "Brightness down precise", brightness_display .. " 1%-", { locked = true, repeating = true })

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- SUPER + SHIFT + C is Calendar (HEY webapp) in preinstalled app binds.
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Cursor", { launch = "cursor", focus = "^Cursor$" })

-- Preinstalled webapp binds are off (preinstalls-removed). Stock X bind
-- is SUPER + SHIFT + X -> omarchy-launch-webapp https://x.com/
o.bind("SUPER + SHIFT + X", "X", { webapp = "https://x.com/" })
o.bind("SUPER + SHIFT + Y", "Y", { webapp = "https://youtube.com/" })
o.bind("SUPER + SHIFT + P", "P", { webapp = "https://podcasts.apple.com/" })
o.bind("SUPER + SHIFT + M", "M", { webapp = "https://music.apple.com/" })
o.bind("SUPER + SHIFT + G", "G", { webapp = "https://grok.com/" })

-- Screenshots use omasnap (~/.local/bin/omasnap). This MacBook has no Print
-- Screen key; Super+Shift+S is the main shortcut. Stock PRINT is also rebound
-- for keyboards that have it. SUPER+SHIFT+S was Google Maps when preinstalled
-- app binds are on.
local omasnap = os.getenv("HOME") .. "/.local/bin/omasnap"
hl.unbind("SUPER + SHIFT + S")
hl.unbind("PRINT")
hl.unbind("SUPER + CTRL + SHIFT + code:12")
hl.unbind("SUPER + CTRL + SHIFT + code:13")
o.bind("SUPER + SHIFT + S", "Screenshot", omasnap)
o.bind("PRINT", "Screenshot", omasnap)
o.bind("SUPER + CTRL + SHIFT + code:12", "Screenshot display", omasnap .. " --capture-fullscreen")
o.bind("SUPER + CTRL + SHIFT + code:13", "Screenshot selection", omasnap .. " --capture-region")

hl.layer_rule({
  match = { namespace = "^omasnap$" },
  no_anim = true,
  animation = "none",
})

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
