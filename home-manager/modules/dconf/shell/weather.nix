{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "org/gnome/shell/weather" = {
      automatic-location = false;
      locations = mkVariant [
        (mkVariant (mkTuple [
          (mkUint32 2)
          (mkVariant (mkTuple [
            "Moscow"
            "UUWW"
            true
            [
              (mkTuple [0.9712757287348443 0.6504260403943177])
            ]
            [
              (mkTuple [0.9730598392028181 0.6565153021683081])
            ]
          ]))
        ]))
      ];
    };
  };
}
