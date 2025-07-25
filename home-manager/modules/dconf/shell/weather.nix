{
  # Не работает, нужно разобраться с форматом указания локации
  dconf.settings = {
    "org/gnome/shell/weather" = {
      automatic-location = false;
      # locations = [
      #   "<(uint32 2, <('Moscow', 'UUWW', true, [(0.97127572873484425, 0.65042604039431762)], [(0.97305983920281813, 0.65651530216830811)])>"
      # ];

      locations = [{
        # This is the Nix representation of the dconf tuple structure
        # The exact format might need adjustment based on how Nix handles dconf tuples
        "0" = 2;  # uint32
        "1" = {
          "0" = "Moscow";
          "1" = "UUWW";
          "2" = true;
          "3" = [[0.97127572873484425 0.65042604039431762]];
          "4" = [[0.97305983920281813 0.65651530216830811]];
        };
      }];
    };
  };
}