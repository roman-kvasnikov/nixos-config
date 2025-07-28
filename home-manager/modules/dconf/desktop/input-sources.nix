{ lib, ... }:

with lib.hm.gvariant;
{
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "ru" ]) ];
      xkb-options = [ "grp:ctrl_shift_toogle" ];
    };
  };
}