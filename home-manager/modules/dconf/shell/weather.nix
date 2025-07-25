{
  # Не работает, нужно разобраться с форматом указания локации
  dconf.settings = {
    "org/gnome/shell/weather" = {
      automatic-location = false;
      locations = pkgs.lib.mkForce [
        "[<(uint32 2, <('Moscow', 'UUWW', true, [(0.97127572873484425, 0.65042604039431762)], [(0.97305983920281813, 0.65651530216830811)])>)>]"
      ];
    };
  };
}