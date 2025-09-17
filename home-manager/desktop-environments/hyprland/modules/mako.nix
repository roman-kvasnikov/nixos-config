{config, ...}: {
  services.mako.settings = {
    enable = true;
  };

  xdg.configFile."mako/config".text = ''
    # [ Global Config ]
    max-history=5

    # arrange notification ( +/- time or +/- priority )
    sort=-time

    # [ BINDING OPTIONS ]
    # Supported values: none, dismiss, dismiss-all,
    # dismiss-group, invoke-default-action & exec <command>

    on-button-left=invoke-default-action
    on-button-middle=dismiss-group
    on-button-right=dismiss
    on-touch=invoke-default-action
    on-notify=exec mpv /usr/share/sounds/freedesktop/stereo/message.oga

    # [ STYLE OPTIONS ]
    # which installed font for notification( any font installed )
    font=${config.home.sessionVariables.FONT_FAMILY} 12
    background-color=#000000CC
    text-color=#c7c7c7
    text-alignment=left
    format= <b>%s</b>\n\n%b

    width=460
    height=190

    outer-margin=0
    margin=10
    padding=5,10

    border-size=2
    border-radius=5

    progress-color=over #0b1c1c

    icons=1

    max-icon-size=34
    icon-location=left

    # enable pango - format notification( value 0|1 )
    # markup=1

    #  Applications may request an action( value 0|1 )
    actions=1

    # mako will save notifications that have reached their timeout into the history buffer in‐
    # stead of immediately deleting them.
    history=1

    default-timeout=10000
    ignore-timeout=0
    max-visible=5

    layer=top
    anchor=top-right

    [urgency=low]
    border-color=#c7c7c7

    [urgency=normal]
    border-color=#c7c7c7

    [urgency=high]
    border-color=#ff3300
    default-timeout=0
  '';
}
