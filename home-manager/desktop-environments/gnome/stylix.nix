{inputs, ...}: {
  imports = [inputs.stylix.homeModules.stylix];

  stylix = {
    targets = {
      gnome.enable = true;
    };
  };
}
