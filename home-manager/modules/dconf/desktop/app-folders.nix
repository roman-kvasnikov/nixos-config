{
  dconf.settings = {

    # App folders
    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "System"
        "Utilities"
        "Tops"
        "Terminals"
        "Office"
        "Multimedia"
        "ImageEditors"
        "TextEditors"
        "Development"
        "Organizer"
      ];
    };

    # System
    "org/gnome/desktop/app-folders/folders/System" = {
      apps = [
        "org.gnome.Nautilus.desktop"
        "org.gnome.DiskUtility.desktop"
        "org.gnome.Logs.desktop"
        "org.gnome.SystemMonitor.desktop"
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
      ];
      name = "Utilities";
      translate = false;
    };

    # Tops
    "org/gnome/desktop/app-folders/folders/Tops" = {
      apps = [
        "bottom.desktop"
        "btop.desktop"
        "htop.desktop"
      ];
      name = "Tops";
      translate = false;
    };

    # Terminals
    "org/gnome/desktop/app-folders/folders/Terminals" = {
      apps = [
        "kitty.desktop"
        "fish.desktop"
        "dev.warp.Warp.desktop"
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
        "org.gnome.Maps.desktop"
        "org.gnome.Weather.desktop"
        "org.gnome.clocks.desktop"
        "org.gnome.Calculator.desktop"
        "obsidian.desktop"
      ];
      name = "Organizer";
      translate = false;
    };
  };
}
