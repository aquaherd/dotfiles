local wezterm = require 'wezterm';

return {
  font = wezterm.font("VictorMono Nerd Font"),
  font_size = 13.0,
  color_scheme = "Dracula",
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  window_background_opacity = 0.90,
  check_for_updates = false,
  pane_focus_follows_mouse = true,
  window_padding = {
    left = 16,
    right = 16,
    top = 16,
    bottom = 16,
  },
  -- audible_bell = "DISABLED",
}
