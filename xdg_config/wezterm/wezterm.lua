local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "nord"
config.bold_brightens_ansi_colors = "No"

config.window_decorations = "RESIZE"

config.font = wezterm.font("Iosevka Term")
config.font_size = 13
config.freetype_load_target = "Normal"
config.allow_square_glyphs_to_overflow_width = "Never"

config.keys = {
    -- Send ssh end session code
    { key = "d", mods = "SHIFT | CMD", action = wezterm.action.SendString("\n~.\n") },

    -- Move to last tab
    { key = "-", mods = "SUPER", action = wezterm.action.ActivateLastTab },

    -- Move between panes with vim like motions
    { key = "h", mods = "SUPER", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "l", mods = "SUPER", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "j", mods = "SUPER", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "k", mods = "SUPER", action = wezterm.action.ActivatePaneDirection("Up") },

    -- Move familiar splits
    { key = "s", mods = "SUPER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "S", mods = "SUPER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "S", mods = "SHIFT | SUPER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- vscode like command palette
    { key = "p", mods = "SUPER", action = wezterm.action.ActivateCommandPalette },

    { key = "-", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
}

return config
