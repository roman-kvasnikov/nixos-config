{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "org/gnome/shell/weather" = {
      automatic-location = false;
      locations = mkArray type.variant [
        (mkTuple [
          (mkUint32 2)
          (mkTuple [
            "Moscow"
            "UUWW" 
            true
            [(mkTuple [0.97127572873484425 0.65042604039431762])]
            [(mkTuple [0.97305983920281813 0.65651530216830811])]
          ])
        ])
      ];
    };
  };
}
