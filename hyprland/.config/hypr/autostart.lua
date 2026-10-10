-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Apple DCP programs Adaptive Sync minRR only on a modeset with VRR already
-- enabled. Re-apply eDP-1 after the session is up so the panel can drop to 24 Hz.
hl.on("hyprland.start", function()
  hl.exec_cmd("omarchy-edp-vrr")
end)
