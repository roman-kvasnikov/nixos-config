{ lib, inputs, pkgs, ... }:

let
  vscodeSettings = builtins.fromJSON (
    builtins.readFile "${inputs.vscode-settings}/settings.min.json"
  );
in {
  programs.vscode = {
    enable = true;

    package = pkgs.code-cursor;

    profiles.default = {
      enableUpdateCheck = false;

      userSettings = vscodeSettings;

      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        esbenp.prettier-vscode
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remotehub";
          publisher = "github";
          version = "0.64.0";
          sha256 = "Nh4PxYVdgdDb8iwHHUbXwJ5ZbMruFB6juL4Yg/wdKMY=";
        }
        {
          name = "github-vscode-theme";
          publisher = "github";
          version = "6.3.5";
          sha256 = "dOadoYBPcYrpzmqOpJwG+/nPwTfJtlsOFDU3FctdR0o=";
        }
        {
          name = "remote-explorer";
          publisher = "ms-vscode";
          version = "0.5.0";
          sha256 = "BNsnetpddxv3Y9MjZERU5jOq1I2g6BNFF1rD7Agpmr8=";
        }
        {
          name = "remote-repositories";
          publisher = "ms-vscode";
          version = "0.42.0";
          sha256 = "cYbkCcNsoTO6E5befw/ZN3yTW262APTCxyCJ/3z84dc=";
        }
      ];
    };
  };
}