{ inputs, pkgs, ... }:

let
  vscodeSettings = builtins.fromJSON (
    builtins.readFile "${inputs.vscode-settings}/settings.json"
  );
in {
  programs.vscode = {
    enable = true;

    package = pkgs.code-cursor;

    # userSettings = vscodeSettings;

    profiles.default = {
      enableUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        # bbenoist.nix
        jnoortheen.nix-ide
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
  };
}