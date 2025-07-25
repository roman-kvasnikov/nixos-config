{ lib, ... }:

{
  dconf.settings = {
    "org/gnome/shell/world-clocks" = {
      locations = lib.mkForce [
        (lib.hive.toDconfValue {
          type = "uv";
          value = [
            2
            {
              _0 = "Dubai";
              _1 = "OMDB";
              _2 = true;
              _3 = [[0.44069563612856821 0.96574884695243146]];
              _4 = [[0.44073441734454749 0.9648180105024653]];
            }
          ];
        })
        (lib.hive.toDconfValue {
          type = "uv";
          value = [
            2
            {
              _0 = "Bangkok";
              _1 = "VTBD";
              _2 = true;
              _3 = [[0.24289166005364171 1.7558012275062955]];
              _4 = [[0.23998277214922031 1.754346792280731]];
            }
          ];
        })
      ];
    };
  };
}