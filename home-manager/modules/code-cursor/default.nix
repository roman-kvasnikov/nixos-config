{ pkgs, ... }:

let
  # Скачиваем settings.json с GitHub (используем raw-ссылку)
  # vscodeSettings = builtins.fromJSON (builtins.readFile (
  #   pkgs.fetchurl {
  #     url = "https://raw.githubusercontent.com/roman-kvasnikov/vscode-settings/refs/heads/master/settings.json";
  #     sha256 = "0000000000000000000000000000000000000000000000000000"; # Замените на реальный хеш
  #   }
  # ));
in {
  programs.vscode = {
    enable = true;
    package = pkgs.code-cursor; # Или pkgs.cursor для Cursor
    # userSettings = vscodeSettings; # Применяем скачанный конфиг
  };
}