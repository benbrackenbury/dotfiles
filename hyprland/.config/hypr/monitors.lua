-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Laptop is the origin; USB-3 sits centered above it.
-- vrr=1 is ProMotion-style Adaptive Sync (DCP minRR 24 Hz = 0x180000).
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = omarchy_monitor_scale, vrr = 1 })
hl.monitor({ output = "USB-3", disabled = false, mode = "4096x2304@59.999Hz", position = "auto-center-up", scale = 1.5, transform = 0, vrr = 0 })
