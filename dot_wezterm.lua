-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.enable_tab_bar = false
config.scrollback_lines = 10000

-- Fixes pipe key shortcut on macos
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

-- Custom key bindings
config.keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {
      key="LeftArrow",
      mods="OPT",
      action=wezterm.action{SendString="\x1bb"}
    },
    -- Make Option-Right equivalent to Alt-f; forward-word
    {
      key="RightArrow",
      mods="OPT",
      action=wezterm.action{SendString="\x1bf"}
    },
}

-- and finally, return the configuration to wezterm
return config

