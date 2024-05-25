local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "nord"
config.bold_brightens_ansi_colors = "No"

config.window_decorations = "RESIZE"

config.font = wezterm.font("Iosevka Term")
config.font_size = 13
config.freetype_load_target = "Normal"

config.keys = {
    { key = "d", mods = "SHIFT | CMD", action = wezterm.action.SendString("\n~.\n") },
    { key = "-", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
}

return config
