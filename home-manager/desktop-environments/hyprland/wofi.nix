{
  programs.wofi = {
    enable = true;

    settings = {
      ## General
      show = "drun";
      prompt = "Search";
      normal_window = true;
      layer = "top";
      term = "kitty";

      ## Geometry
      width = 500;
      height = 700;
      location = "center";
      columns = 1;
      orientation = "vertical";
      halign = "fill";
      line_wrap = "off";
      dynamic_lines = false;

      ## Images
      allow_markup = true;
      allow_images = true;
      image_size = 32;

      ## Search
      exec_search = false;
      hide_search = false;
      parse_search = false;
      insensitive = true;

      ## Other
      hide_scroll = false;
      no_actions = true;
      sort_order = "default";
      gtk_dark = true;
      filter_rate = 100;

      ## Keys
      key_expand = "Tab";
      key_exit = "Escape";
    };

    style = ''
      #window {
        margin: 0px;
        border: none;
      }

      #input {
        margin: 10px;
        border: none;
        border-radius: 5px;
        font-size: 18px;
      }

      #inner-box {
        margin: 5px;
        border: none;
        border-radius: 5px;
        background-color: #2e3440;
      }

      #outer-box {
        margin: 5px;
        border: none;
        border-radius: 5px;
        background-color: #2e3440;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #eceff4;
        font-size: 18px;
      }

      #entry {
        margin: 5px;
        padding: 6px;
        border: none;
        border-radius: 5px;
      }
    '';
  };
}
