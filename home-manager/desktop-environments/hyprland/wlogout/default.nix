{
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
        label = "logout";
        action = "notify-send 'Logging out...'&hyprctl dispatch exit 0";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "hyprlock -f & systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "shutdown";
        action = "notify-send 'Shutting down...' &systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
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
    ];

    style = ''
      /* Base border color*/
      @define-color border-main @fg-main;
      @define-color border-alt @fg-main;

      /* Background Colors */
      @define-color bg-main #11111B;
      @define-color bg-alt #939CDA;
      @define-color bg-hover #484872;
      @define-color bg-hover-alt #30304D;
      @define-color bg-tooltip @bg-main;
      @define-color bg-second #33334C;
      @define-color bg-third #939CDA;
      @define-color sway-bg @bg-main;

      /*text color for entries, views and content in general */
      @define-color fg-main #B4BEFE;
      @define-color fg-unactive @bg-hover;
      @define-color content-act #CDD4FF;


      /* Player colors */
      @define-color ply-main #25253B;
      @define-color ply-hover #363657;
      @define-color ply-act #515181;
      @define-color msc-act #424268;

      /* Wlogout */

      @define-color wlogout-hover rgba(37, 37, 68, 0.541);
      @define-color wlogout-bg rgba(17, 17, 17, 0.45);
      @define-color wlogout-button rgba(17, 17, 27, 0.781);

      * {
          background-image: none;
          font-size: 20px;
          font-family: "Jetbrains Mono";
      }

      window {
          background-color: @wlogout-bg;
      }

      button {
          border-radius: 0px;
          color: @fg-main;
          border-color: @border-main;
          background-color: @wlogout-button;
          outline-style: none;
          border-style: solid;
          border-width: 3px;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 20%;
          box-shadow: none;
          text-shadow: none;
          animation: gradient_f 20s ease-in infinite;
      }

      button:hover,button:focus {
          background-color: @wlogout-hover;
          background-size: 30%;
          animation: gradient_f 20s ease-in infinite;
          transition: all 0.3s cubic-bezier(.55,0.0,.28,1.682);
      }

      button:active {
          background-color: @bg-hover;
      }

      #lock {
          border-top-left-radius: 15px;
          background-image: url('${config.xdg.configHome}/wlogout/icons/lock.png');
      }

      #logout {
          border-bottom-left-radius: 15px;
          background-image: url('${config.xdg.configHome}/wlogout/icons/logout.png');
      }

      #suspend {
          background-image: url('${config.xdg.configHome}/wlogout/icons/suspend.png');
      }

      #hibernate {
          border-top-right-radius: 15px;
          background-image: url('${config.xdg.configHome}/wlogout/icons/hibernate.png');
      }

      #shutdown {
          background-image: url('${config.xdg.configHome}/wlogout/icons/shutdown.png');
      }

      #reboot {
          border-bottom-right-radius: 15px;
          background-image: url('${config.xdg.configHome}/wlogout/icons/reboot.png');
      }

      #lock, #suspend,#hibernate {
          border-bottom: @border-main solid 1px;
      }

      #logout,#shutdown,#reboot {
          border-top: @border-main solid 1px;
      }

      #logout,#lock,#suspend,#shutdown{
          border-right: @border-main solid 1px;
      }

      #suspend,#shutdown,#hibernate,#reboot{
          border-left: @border-main solid 1px;
      }
    '';
  };

  xdg.configFile = {
    "wlogout/icons/lock.png".source = ./wlogout/icons/lock.png;
    "wlogout/icons/logout.png".source = ./wlogout/icons/logout.png;
    "wlogout/icons/suspend.png".source = ./wlogout/icons/suspend.png;
    "wlogout/icons/shutdown.png".source = ./wlogout/icons/shutdown.png;
    "wlogout/icons/hibernate.png".source = ./wlogout/icons/hibernate.png;
    "wlogout/icons/reboot.png".source = ./wlogout/icons/reboot.png;
  };
}
