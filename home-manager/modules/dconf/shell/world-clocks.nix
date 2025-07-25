{ lib, ... }:

{
  # Не работает, нужно разобраться с форматом указания локации
  dconf.settings = {
    "org/gnome/clocks" = {
      world-clocks = [
        ([ 
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [
            (mkUint32 2)
            (mkVariant (mkTuple [
              "Dubai"
              "OMDB"
              true
              [(mkTuple [(0.44069563612856821) (0.96574884695243146)])]
              [(mkTuple [(0.44073441734454749) (0.9648180105024653)])]
            ]))
          ]))])
        ])
        ([ 
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [
            (mkUint32 2)
            (mkVariant (mkTuple [
              "Bangkok"
              "VTBD"
              true
              [(mkTuple [(0.24289166005364171) (1.7558012275062955)])]
              [(mkTuple [(0.23998277214922031) (1.754346792280731)])]
            ]))
          ]))])
        ])
      ];
    };
  };
}