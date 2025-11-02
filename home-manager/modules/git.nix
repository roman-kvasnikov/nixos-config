{lib, ...}: {
  programs.git = lib.mkForce {
    enable = true;

    settings = {
      user = {
        name = "RomanK";
        email = "roman.kvasnikov@gmail.com";
      };
    };
  };
}
