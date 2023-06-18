local wezterm = require 'wezterm'
local act = wezterm.action
local default_prog
local zen = false
local set_environment_variables = {}
local padTop = 16

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    default_prog = { 'powershell.exe' }
    padTop = 64
end

wezterm.on('toggle-zen-mode', function(window, _)
    local overrides = window:get_config_overrides() or {}
    zen = not zen
    if window:get_dimensions().is_full_screen then
        return
    end
    if zen then
        overrides.window_decorations = "RESIZE"
        overrides.enable_tab_bar = false
        overrides.window_padding = { left = 16, right = 16, top = padTop, bottom = 16 }
    else
        overrides.window_decorations = "TITLE | RESIZE"
        overrides.enable_tab_bar = true
        overrides.window_padding = { left = 16, right = 16, top = 16, bottom = 16 }
    end
    window:set_config_overrides(overrides)
end)

return {
    -- audible_bell = "DISABLED",
    adjust_window_size_when_changing_font_size = false,
    check_for_updates = false,
    color_scheme = "Dracula",
    default_gui_startup_args = { 'connect', 'unix' },
    default_prog = default_prog,
    font = wezterm.font("Iosevka"),
    font_size = 13.0,
    hide_tab_bar_if_only_one_tab = true,
    -- hide_mouse_cursor_when_typing = true,   
    pane_focus_follows_mouse = true,
    set_environment_variables = set_environment_variables,
    tab_bar_at_bottom = true,
    unix_domains = {  { name = 'unix' } },
    window_background_opacity = 0.90,

    window_padding = { left = 16, right = 16, top = 16, bottom = 16 },

    keys = {
        { key = 'd', mods = 'ALT', action = act.SplitHorizontal },
        { key = 'd', mods = 'ALT|SHIFT', action = act.SplitVertical },
        { key = 'n', mods = 'ALT|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
        { key = 'Space', mods = 'ALT|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|DOMAINS' } },
        { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
        { key = 'LeftArrow', mods = 'SHIFT|ALT', action = act.AdjustPaneSize{ 'Left', 1 } },
        { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
        { key = 'RightArrow', mods = 'SHIFT|ALT', action = act.AdjustPaneSize{ 'Right', 1 } },
        { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
        { key = 'UpArrow', mods = 'SHIFT|ALT', action = act.AdjustPaneSize{ 'Up', 1 } },
        { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
        { key = 'DownArrow', mods = 'SHIFT|ALT', action = act.AdjustPaneSize{ 'Down', 1 } },
        { key = 'q', mods = 'CTRL|SHIFT', action = act.QuitApplication },
        { key = 'Enter', mods = 'CTRL|SHIFT', action = act.EmitEvent 'toggle-zen-mode' },
    },

    tls_clients = {
        { name = 'pc198', remote_address = 'pc198:8192', bootstrap_via_ssh = 'z003tnse@pc198' },
        { name = 'rda', remote_address = 'win043:8192', bootstrap_via_ssh = 'z003tnse@win043', accept_invalid_hostnames = true },
    },

    ssh_domains = {
        { name = 'pc105', remote_address = '192.168.23.105', username = 'Tester' }, -- OK
        { name = 'pc106', remote_address = '192.168.188.106', username = 'sshuser' }, -- OK
        { name = 'pc107', remote_address = '192.168.23.107', username = 'sshuser' }, -- OK
        { name = 'pc108', remote_address = '192.168.23.108', username = 'sshuser' }, -- KO
        { name = 'pc249', remote_address = '192.168.23.249', username = 'Tester' }, -- KO
        { name = 'pg2', remote_address = 'nina.erduman.de:20022', username = 'hakan' },
    }
}

