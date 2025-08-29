{
  programs.wofi = {
    enable = true;

    settings = {
      show = "drun";
      width = 600;
      height = 400;
      location = "center";
      columns = 2;
      orientation = "vertical";
      halign = "fill";
      line_wrap = "off";
      dynamic_lines = false;
      allow_markup = true;
      allow_images = true;
      image_size = 32;
      exec_search = false;
      hide_search = false;
      parse_search = false;
      insensitive = true;
      hide_scroll = false;
      no_actions = true;
      sort_order = "default";
      gtk_dark = true;
      filter_rate = 100;
      key_expand = "Tab";
      key_exit = "Escape";
    };

    style = ''
      window {
        margin: 0px;
        border: 1px solid #3b4252;
        background-color: #2e3440;
        border-radius: 10px;
      }

      #input {
        margin: 5px;
        border: none;
        color: #eceff4;
        background-color: #3b4252;
        border-radius: 5px;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: #2e3440;
      }

      #outer-box {
        margin: 5px;
        border: none;
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
      }

      #entry {
        margin: 2px;
        border: none;
        border-radius: 5px;
      }

      #entry:selected {
        background-color: #4c566a;
      }
    '';
  };
}
