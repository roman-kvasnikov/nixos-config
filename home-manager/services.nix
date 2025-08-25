{
  services = {
    ssh-agent = {
      enable = true;
    };

    xrayctl = {
      enable = true;
    };

    homevpnctl = {
      enable = true;
    };

    keepassxcctl = {
      enable = true;
    };

    s3fsctl = {
      enable = false; # Временно отключено из-за проблем с бесконечными процессами
    };
  };
}
