{
  dconf.settings = {
    # Default
    "org/gnome/desktop/app-folders/folder-children" = {
      apps = [
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

    # Image Editors
    "org/gnome/desktop/app-folders/ImageEditors" = {
      apps = [
        "gimp.desktop"
        "org.inkscape.Inkscape.desktop"
        "org.kde.krita.desktop"
        "pinta.desktop"
      ];
      categories = [
        "Graphics"
        "2DGraphics"
        "RasterGraphics"
        "ImageEditor"
      ];
      name = "Image Editors";
      translate = false;
    };

    # Development
    "org/gnome/desktop/app-folders/Development" = {
      apps = [
        "cursor.desktop"
        "filezilla.desktop"
        "postman.desktop"
      ];
      categories = [
        "Development"
        "Network"
        "WebDevelopment"
      ];
      name = "Development";
      translate = false;
    };

    # Tops
    "org/gnome/desktop/app-folders/Tops" = {
      apps = [
        "bottom.desktop"
        "btop.desktop"
        "htop.desktop"
      ];
      categories = [
        "System"
        "Monitor"
      ];
      name = "Tops";
      translate = false;
    };

    # Terminals
    "org/gnome/desktop/app-folders/Terminals" = {
      apps = [
        "kitty.desktop"
        "fish.desktop"
        "dev.warp.Warp.desktop"
      ];
      categories = [
        "TerminalEmulator"
        "Shell"
        "Development"
      ];
      name = "Terminals";
      translate = false;
    };

    # Office
    "org/gnome/desktop/app-folders/Office" = {
      apps = [
        "startcenter.desktop"
        "base.desktop"
        "calc.desktop"
        "draw.desktop"
        "impress.desktop"
        "math.desktop"
        "writer.desktop"
      ];
      categories = [
        "Office"
        "OfficeSuite"
        "OfficeSuiteSuite"
      ];
      name = "Office";
      translate = false;
    };

    # Multimedia
    "org/gnome/desktop/app-folders/Multimedia" = {
      apps = [
        "org.gnome.Decibels.desktop"
        "vlc.desktop"
      ];
      categories = [
        "Multimedia"
        "AudioVideo"
        "Audio"
        "Video"
      ];
      name = "Multimedia";
      translate = false;
    };

    # Organizer
    "org/gnome/desktop/app-folders/Organizer" = {
      apps = [
        "org.gnome.Calendar.desktop"
        "org.gnome.Maps.desktop"
        "org.gnome.Weather.desktop"
        "org.gnome.clocks.desktop"
        "org.gnome.Calculator.desktop"
      ];
      categories = [
        "Office"
        "OfficeSuite"
        "OfficeSuiteSuite"
      ];
      name = "Organizer";
      translate = false;
    };

    # Text Editors
    "org/gnome/desktop/app-folders/TextEditors" = {
      apps = [
        "org.gnome.TextEditor.desktop"
        "micro.desktop"
      ];
      categories = [
        "TextEditor"
        "Text"
        "OfficeSuiteSuite"
      ];
      name = "Text Editors";
      translate = false;
    };
  };
}
