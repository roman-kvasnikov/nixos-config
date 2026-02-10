{user, ...}: {
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

    # keepassxcctl = {
    #   enable = false;
    # };

    s3fsctl = {
      enable = true;

      buckets = {
        izolda-rally = {
          bucket = "1f382b96-c34b0ea3-eb1f-4476-b009-6e99275d7b19";
          mountPoint = "/home/${user.name}/mnt/Izolda-Rally";
          url = "https://s3.twcstorage.ru";
          endpoint = "s3.twcstorage.ru";
          passwordFile = "/home/${user.name}/.config/s3fsctl/.passwd-izolda-rally"; # Не забудь chmod 600
        };
      };
    };
  };
}
