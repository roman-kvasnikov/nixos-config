{user, ...}: {
  environment = {
    etc."/brave/policies/managed/GroupPolicy.json".source = "${user.dirs.nixos-config}/home-manager/modules/brave/policies.json";

    sessionVariables = rec {
      TERMINAL = "kitty";
      EDITOR = "nano";
      XDG_BIN_HOME = "$HOME/.local/bin";
      PATH = [
        "${XDG_BIN_HOME}"
      ];
    };
  };
}
