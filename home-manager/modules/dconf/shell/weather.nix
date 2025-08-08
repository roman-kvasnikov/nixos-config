{pkgs, lib, ...}: {
  home.activation.setupWeather = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.glib}/bin/gsettings set org.gnome.shell.weather automatic-location false
    ${pkgs.glib}/bin/gsettings set org.gnome.shell.weather locations "[<(uint32 2, <('Moscow', 'UUWW', true, 
  [(0.9712757287348443, 0.6504260403943177)], [(0.9730598392028181, 0.6565153021683081)])>)>]"
  '';
}
