{ lib, ... }:

{
  programs.git = lib.mkForce {
    enable = true;
    userName = "RomanK";
    userEmail = "roman.kvasnikov@gmail.com";
  };
}
