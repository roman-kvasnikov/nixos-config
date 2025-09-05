{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Загружаем Sugar Candy тему с GitHub
  sddm-sugar-candy-src = pkgs.fetchFromGitHub {
    owner = "Kangie";
    repo = "sddm-sugar-candy";
    rev = "a1659cf2a47c96b5b9d65e77af9ee40dc1c7722d";
    sha256 = "sha256-p2d7W4b6HjYs5d3g2ZKUm4bPgS3sBVvNSNQWOm6rKuQ=";
  };

  # Создаем кастомную тему с нашими настройками
  sddm-sugar-candy-custom = pkgs.stdenv.mkDerivation {
    pname = "sddm-sugar-candy-custom";
    version = "1.0";

    src = sddm-sugar-candy-src;

    dontBuild = true;

    installPhase = ''
            mkdir -p $out/share/sddm/themes/sugar-candy

            # Копируем все файлы темы
            cp -r $src/* $out/share/sddm/themes/sugar-candy/

            # Создаем theme.conf с нашими настройками
            cat > $out/share/sddm/themes/sugar-candy/theme.conf << EOF
      [General]
      Background="${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png"
      ScreenWidth=1920
      ScreenHeight=1080
      ThemeColor="navajowhite"
      AccentColor="#fb884f"
      BackgroundColor="#1e1e2e"
      OverrideLoginButtonTextColor=""
      InterfaceShadowSize=6
      InterfaceShadowOpacity=0.6
      RoundCorners=20
      ScreenPadding=0
      Font="Ubuntu"
      FontSize=""
      ForceRightToLeft=false
      ForceLastUser=true
      ForcePasswordFocus=true
      ForceHideCompletePassword=false
      ForceHideVirtualKeyboardButton=false
      ForceHideSystemButtons=false
      AllowEmptyPassword=false
      AllowBadUsernames=false
      Locale=""
      HourFormat="HH:mm"
      DateFormat="dddd, MMMM d, yyyy"
      HeaderText="Welcome!"
      TranslatePlaceholderUsername=""
      TranslatePlaceholderPassword=""
      TranslateShowPassword=""
      TranslateLogin=""
      TranslateLoginFailed=""
      TranslateCapsLockWarning=""
      TranslateSession=""
      TranslateSuspend=""
      TranslateHibernate=""
      TranslateReboot=""
      TranslateShutdown=""
      TranslateVirtualKeyboardButton=""
      EOF
    '';
  };
in {
  # Добавляем пакет в систему
  environment.systemPackages = with pkgs; [
    sddm-sugar-candy-custom
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtsvg
  ];

  # Настраиваем SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sugar-candy";

    settings = {
      Theme = {
        ThemeDir = "${sddm-sugar-candy-custom}/share/sddm/themes";
        Current = "sugar-candy";
      };
      General = {
        HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
        RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
      };
    };
  };
}
