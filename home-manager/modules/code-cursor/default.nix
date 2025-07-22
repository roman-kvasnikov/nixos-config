{ pkgs, user, ... }:

let
  # vscodeSettings = builtins.fromJSON (
  #   builtins.readFile "./settings.json"
  # );
in {
  programs.vscode = {
    enable = true;
    package = pkgs.code-cursor;
    # extensions = with pkgs.vscode-extensions; [
    #   saeed-nazari.adonis-theme
    #   formulahendry.auto-close-tag
    #   formulahendry.auto-rename-tag
    #   ms-vscode.azure-repos
    #   github.remotehub
    #   github.github-vscode-theme
    #   jnoortheen.nix-ide
    #   ms-vscode-remote.remote-ssh
    #   ms-vscode-remote.remote-ssh-edit
    #   ms-vscode.remote-explorer
    #   ms-vscode.remote-repositories
    # ];
    # userSettings = vscodeSettings;
  };
}