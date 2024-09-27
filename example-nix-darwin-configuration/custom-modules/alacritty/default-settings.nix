{
  env = {
    "TERM" = "xterm-256color";
  };

  selection.save_to_clipboard = true;
  live_config_reload = true;

  mouse.bindings = [
    { mouse = "Right"; action = "Paste"; }
  ];

  window = {
    padding.x = 10;
    padding.y = 10;
    decorations = "Full";
    blur = true;
    opacity = 0.95;
    dimensions = {
      columns = 150;
      lines = 50;
    };
  };

  scrolling = {
    history = 10000;
    multiplier = 40;
  };

  font = {
    size = 12.0;
    normal = { family = "FiraCode Nerd Font"; style = "Light"; };
    bold = { family = "FiraCode Nerd Font"; style = "Semibold"; };
    italic.family = "FiraCode Nerd Font";
  };

  cursor.style = "Beam";

  keyboard.bindings = [
    {
      key = "W";
      mods = "Command";
      action = "ToggleFullscreen";
    }
    {
      key = "N";
      mods = "Command|Shift";
      action = "SpawnNewInstance";
    }
    {
      key = "F";
      mods = "Command|Shift";
      action = "ToggleFullscreen";
    }
    {
      key = "Equals";
      mods = "Command|Shift";
      action = "IncreaseFontSize";
    }
    {
      key = "Minus";
      mods = "Command|Shift";
      action = "DecreaseFontSize";
    }
    # Use command + [ - to go to previous tmux window
    {
      key = "LBracket";
      mods = "Command";
      chars = "\x5c\x70";
    }
    # Use command + ] - to go to previous tmux window
    {
      key = "RBracket";
      mods = "Command";
      chars = "\x5c\x6e";
    }
    # ctrl-^ doesn't work in some terminals like alacritty
    {
      key = "Key6";
      mods = "Control";
      chars = "\x1e";
    }

  ];

  colors = {
    primary = {
      background = "#1a1b26";
      foreground = "#a9b1d6";
    };
    # Normal colors
    normal = {
      black = "#32344a";
      red = "#f7768e";
      green = "#9ece6a";
      yellow = "#e0af68";
      blue = "#7aa2f7";
      magenta = "#ad8ee6";
      cyan = "#449dab";
      white = "#787c99";
    };
    # Bright colors
    bright = {
      black = "#444b6a";
      red = "#ff7a93";
      green = "#b9f27c";
      yellow = "#ff9e64";
      blue = "#7da6ff";
      magenta = "#bb9af7";
      cyan = "#0db9d7";
      white = "#acb0d0";
    };
  };
}