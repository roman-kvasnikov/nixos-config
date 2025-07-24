{ inputs, pkgs, ... }:

let
  rawJson = builtins.readFile "${inputs.vscode-settings}/settings.json";
  jsonWithoutComments = pkgs.runCommand "clean-json" {} ''
    ${pkgs.jq}/bin/jq -c '.' < "${rawJson}" > $out
  '';
  vscodeSettings = builtins.fromJSON (builtins.readFile jsonWithoutComments);



  # vscodeSettings = builtins.fromJSON (
  #   builtins.readFile "${inputs.vscode-settings}/settings.json"
  # );
in {
  programs.vscode = {
    enable = true;

    package = pkgs.code-cursor;

    enableUpdateCheck = false;

    userSettings = vscodeSettings;

    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix # Nix language support
      esbenp.prettier-vscode # General formatting plugin
      # open-southeners.laravel-pint
      # shufo.vscode-blade-formatter
      # saeed-nazari.adonis-theme
      # formulahendry.auto-close-tag
      # formulahendry.auto-rename-tag
      # ms-vscode.azure-repos
      # github.remotehub
      # github.github-vscode-theme
      # jnoortheen.nix-ide
      # ms-vscode-remote.remote-ssh
      # ms-vscode-remote.remote-ssh-edit
      # ms-vscode.remote-explorer
      # ms-vscode.remote-repositories
    ];
  };
}