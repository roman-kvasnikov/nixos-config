{config, ...}: {
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "suspend";
        action = "hyprlock -f & systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "logout";
        action = "notify-send 'Logging out...'&hyprctl dispatch exit 0";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "notify-send 'Shutting down...' &systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
    ];

    style = ''
      @define-color bg-color rgba(17, 17, 17, 0.8);
      @define-color font-color #B4BEFE;
      @define-color border-color #B4BEFE;
      @define-color button-bg-color rgba(37, 37, 68, 0.6);
      @define-color button-bg-color-hover rgba(17, 17, 27, 0.8);

      * {
          background-image: none;
          font-family: "${config.home.sessionVariables.FONT_FAMILY}";
          font-size: 20px;
      }

      window {
          background-color: @bg-color;
      }

      button {
          color: @font-color;
          border-color: @border-color;
          border-style: solid;
          border-width: 3px;
          border-radius: 0px;
          outline-style: none;
          background-color: @button-bg-color;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 20%;
          box-shadow: none;
          text-shadow: none;
          animation: gradient_f 20s ease-in infinite;
      }

      button:hover,button:focus {
          background-color: @button-bg-color-hover;
          background-size: 25%;
          animation: gradient_f 20s ease-in infinite;
          transition: all 0.3s cubic-bezier(.55,0.0,.28,1.682);
      }

      #lock {
          border-top-left-radius: 15px;
          background-image: url('${config.xdg.configHome}/wlogout/icons/lock.png');
      }

      #logout {
          background-image: url('${config.xdg.configHome}/wlogout/icons/logout.png');
      }

      #reboot {
          border-top-right-radius: 15px;
          background-image: url('${config.xdg.configHome}/wlogout/icons/reboot.png');
      }

      #suspend {
          border-bottom-left-radius: 15px;
          background-image: url('${config.xdg.configHome}/wlogout/icons/suspend.png');
      }

      #hibernate {
          background-image: url('${config.xdg.configHome}/wlogout/icons/hibernate.png');
      }

      #shutdown {
          border-bottom-right-radius: 15px;
          background-image: url('${config.xdg.configHome}/wlogout/icons/shutdown.png');
      }

      #lock, #logout, #reboot {
          border-bottom: @border-color solid 1px;
      }

      #suspend, #hibernate, #shutdown {
          border-top: @border-color solid 1px;
      }

      #lock, #suspend, #logout, #hibernate{
          border-right: @border-color solid 1px;
      }

      #logout, #hibernate, #reboot, #shutdown{
          border-left: @border-color solid 1px;
      }
    '';
  };

  xdg.configFile = {
    "wlogout/icons/lock.png".source = ./icons/lock.png;
    "wlogout/icons/logout.png".source = ./icons/logout.png;
    "wlogout/icons/suspend.png".source = ./icons/suspend.png;
    "wlogout/icons/shutdown.png".source = ./icons/shutdown.png;
    "wlogout/icons/hibernate.png".source = ./icons/hibernate.png;
    "wlogout/icons/reboot.png".source = ./icons/reboot.png;
  };
}
