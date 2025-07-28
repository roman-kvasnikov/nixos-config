{ inputs, ... }:

{
  # imports = [ inputs.stylix.homeModules.stylix ];

  stylix = {
    enable = true;

    targets = {
      vscode.enable = false;
    };
  };
}