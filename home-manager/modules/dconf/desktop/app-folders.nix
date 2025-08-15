{lib, ...}: {
  dconf.settings = {
    # App folders
    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "System"
        "Utilities"
        "Terminals"
        "Office"
        "Multimedia"
        "ImageEditors"
        "TextEditors"
        "Development"
        "Organizer"
        "Crypto"
      ];
    };

    "org/gnome/shell" = let
      apps = [
        "System"
        "Utilities"
        "Terminals"
        "Development"
        "Office"
        "Multimedia"
        "ImageEditors"
        "TextEditors"
        "Organizer"
        "Crypto"
        "org.gnome.Extensions.desktop"
        "nixos-manual.desktop"
        "org.gnome.Settings.desktop"
      ];

      mkAppEntry = name: pos:
        with lib.hm.gvariant;
          mkDictionaryEntry [
            name
            (mkVariant (mkDictionaryEntry ["position" (mkVariant (mkInt32 pos))]))
          ];
    in {
      app-picker-layout = [
        (lib.imap0 (i: name: mkAppEntry name i) apps)
      ];
    };

    # System
    "org/gnome/desktop/app-folders/folders/System" = {
      apps = [
        "bottom.desktop"
        "btop.desktop"
        "htop.desktop"
        "org.gnome.SystemMonitor.desktop"
        "org.gnome.DiskUtility.desktop"
        "org.gnome.Logs.desktop"
      ];
      name = "System";
      translate = false;
    };

    # Utilities
    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [
        "org.gnome.Connections.desktop"
        "org.gnome.Evince.desktop"
        "org.gnome.Loupe.desktop"
        "yazi.desktop"
      ];
      name = "Utilities";
      translate = false;
    };

    # Terminals
    "org/gnome/desktop/app-folders/folders/Terminals" = {
      apps = [
        "dev.warp.Warp.desktop"
        "kitty.desktop"
        "xterm.desktop"
        "fish.desktop"
      ];
      name = "Terminals";
      translate = false;
    };

    # Office
    "org/gnome/desktop/app-folders/folders/Office" = {
      apps = [
        "startcenter.desktop"
        "base.desktop"
        "calc.desktop"
        "draw.desktop"
        "impress.desktop"
        "math.desktop"
        "writer.desktop"
      ];
      name = "Office";
      translate = false;
    };

    # Multimedia
    "org/gnome/desktop/app-folders/folders/Multimedia" = {
      apps = [
        "org.gnome.Decibels.desktop"
        "vlc.desktop"
        "org.gnome.Snapshot.desktop"
      ];
      name = "Multimedia";
      translate = false;
    };

    # Image Editors
    "org/gnome/desktop/app-folders/folders/ImageEditors" = {
      apps = [
        "gimp.desktop"
        "org.inkscape.Inkscape.desktop"
        "org.kde.krita.desktop"
        "pinta.desktop"
      ];
      name = "Image Editors";
      translate = false;
    };

    # Text Editors
    "org/gnome/desktop/app-folders/folders/TextEditors" = {
      apps = [
        "org.gnome.TextEditor.desktop"
        "micro.desktop"
      ];
      name = "Text Editors";
      translate = false;
    };

    # Development
    "org/gnome/desktop/app-folders/folders/Development" = {
      apps = [
        "cursor.desktop"
        "filezilla.desktop"
        "postman.desktop"
      ];
      name = "Development";
      translate = false;
    };

    # Organizer
    "org/gnome/desktop/app-folders/folders/Organizer" = {
      apps = [
        "org.gnome.Calendar.desktop"
        "org.gnome.Calculator.desktop"
        "obsidian.desktop"
        "org.gnome.clocks.desktop"
        "org.gnome.Weather.desktop"
        "org.gnome.Maps.desktop"
      ];
      name = "Organizer";
      translate = false;
    };

    # Crypto
    "org/gnome/desktop/app-folders/folders/Crypto" = {
      apps = [
        "electrum.desktop"
        "exodus.desktop"
      ];
      name = "Crypto";
      translate = false;
    };
  };
}
