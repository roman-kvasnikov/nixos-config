{inputs}: {
  imports = [
    inputs.android-nixpkgs
  ];

  android-sdk = {
    enable = true;

    # Optional; default path is "~/.local/share/android".
    # path = "${config.home.homeDirectory}/.android/sdk";

    packages = sdkPkgs:
      with sdkPkgs; [
        build-tools-34-0-0
        cmdline-tools-latest
        emulator
        platforms-android-34
        sources-android-34
      ];
  };
}
