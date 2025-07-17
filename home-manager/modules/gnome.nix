{ pkgs, user, ... }:

{
  home-manager.users.${user} = {
    dconf = {
      enable = true;
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          bitcoin-markets.extensionUuid
          blur-my-shell.extensionUuid
          caffeine.extensionUuid
          clipboard-history.extensionUuid
          dash-to-dock.extensionUuid
          desktop-cube.extensionUuid
          search-light.extensionUuid
        ];
      };

      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };
}