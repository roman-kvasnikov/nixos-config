{ lib, ... }:

{
  # Не работает, нужно разобраться с форматом указания локации
  dconf = {
    settings = let
      inherit (lib.gvariant) mkTuple mkUint32 mkVariant;
    in {
      "org/gnome/clocks" = {
        world-clocks = [
          {
            location = mkVariant [(mkUint32 2) (mkVariant ["Oslo" "ENGM" false [(mkTuple [1.0506882097005865 0.19344065294494067])] [(mkTuple [1.0506882097005865 0.19344065294494067])]])];
          }
          {
            location = mkVariant [(mkUint32 2) (mkVariant ["London" "EGWU" false [(mkTuple [0.8997172294030767 (-7.272211034407213e-3)])] [(mkTuple [0.8997172294030767 (-7.272211034407213e-3)])]])];
          }
          {
            location = mkVariant [(mkUint32 2) (mkVariant ["Sydney" "YSSY" true [(mkTuple [(-0.592539281052075) 2.638646934988996])] [(mkTuple [(-0.5913757223996479) 2.639228723041856])]])];
          }
        ];
      };
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