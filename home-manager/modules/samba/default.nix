{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    samba
  ];

  fileSystems."/home/${config.home.username}/mnt/smb/shared" = {
    device = "//192.168.1.20/shared";
    fsType = "cifs";
    options = [
      "credentials=/home/${config.home.username}/.config/nixos/home-manager/modules/samba/.smb-secrets"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "nofail"
      "noatime"

      # чтобы файлы были от твоего пользователя
      "uid=1000"
      "gid=100"

      # современный протокол (важно!)
      "vers=3.1.1"
    ];
  };
}
