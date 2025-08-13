{lib, ...}: {
  dconf.settings = {
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 900; # 15 минут в секундах
    };
  };
}
