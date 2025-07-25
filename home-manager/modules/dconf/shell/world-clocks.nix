{ lib, ... }:

{
  # Не работает, нужно разобраться с форматом указания локации
  dconf = {
    settings = let
      inherit (lib.gvariant) mkTuple mkUint32 mkVariant;
    in {
      "org/gnome/clocks" = {
      world-clocks = [
        ([ 
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [
            (mkUint32 2)
            (mkVariant (mkTuple [
              "Kos"
              "LGKO"
              true
              [(mkTuple [(0.64199027070748338) (0.47240245669089603)])]
              [(mkTuple [(0.64391013288467702) (0.47628096226126287)])]
            ]))
          ]))])
        ])
        ([ 
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [
            (mkUint32 2)
            (mkVariant (mkTuple [
              "Richmond"
              "KRIC"
              true
              [(mkTuple [(0.65469239303106264) (-1.3495467494659847)])]
              [(mkTuple [ (0.65543672359716076) (-1.351936611357448)])]
            ]))
          ]))])
        ])
      ];
    };
  };
}






    # "org/gnome/clocks" = {
    #   world-clocks = lib.mkForce [
    #     "[<(2, <('Dubai', 'OMDB', true, [(0.44069563612856821, 0.96574884695243146)], [(0.44073441734454749, 0.9648180105024653)])>)>]"
    #     "[<(2, <('Bangkok', 'VTBD', true, [(0.24289166005364171, 1.7558012275062955)], [(0.23998277214922031, 1.754346792280731)])>)>]"
    #   ];
    # };
  # };
# }