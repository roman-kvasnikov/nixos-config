{
  pkgs,
  ...
}: {
  # Создание группы ImageEditors
  environment.etc."xdg/applications/image-editors.desktop".text = ''
    [Desktop Entry]
    Name=Image Editors
    Comment=Graphic editors and tools for working with images
    Exec=
    Icon=applications-graphics
    Type=Application
    Categories=Graphics;2DGraphics;RasterGraphics;
    NoDisplay=false
  '';

  # Создание .desktop файлов для каждого приложения с указанием группы
  environment.etc."xdg/applications/pinta-custom.desktop".text = ''
    [Desktop Entry]
    Name=Pinta
    Comment=Simple image editor
    Exec=${pkgs.pinta}/bin/pinta
    Icon=pinta
    Type=Application
    Categories=Graphics;2DGraphics;RasterGraphics;ImageEditor;
    Keywords=draw;drawing;paint;painting;graphics;raster;2d;
    NoDisplay=false
  '';

  environment.etc."xdg/applications/krita-custom.desktop".text = ''
    [Desktop Entry]
    Name=Krita
    Comment=Digital drawing and painting
    Exec=${pkgs.krita}/bin/krita
    Icon=krita
    Type=Application
    Categories=Graphics;2DGraphics;RasterGraphics;ImageEditor;
    Keywords=draw;drawing;paint;painting;graphics;raster;2d;
    NoDisplay=false
  '';

  environment.etc."xdg/applications/gimp-custom.desktop".text = ''
    [Desktop Entry]
    Name=GIMP
    Comment=Raster image editor
    Exec=${pkgs.gimp}/bin/gimp
    Icon=gimp
    Type=Application
    Categories=Graphics;2DGraphics;RasterGraphics;ImageEditor;
    Keywords=draw;drawing;paint;painting;graphics;raster;2d;
    NoDisplay=false
  '';

  environment.etc."xdg/applications/inkscape-custom.desktop".text = ''
    [Desktop Entry]
    Name=Inkscape
    Comment=Vector graphics editor
    Exec=${pkgs.inkscape}/bin/inkscape
    Icon=inkscape
    Type=Application
    Categories=Graphics;2DGraphics;VectorGraphics;ImageEditor;
    Keywords=draw;drawing;paint;painting;graphics;vector;2d;
    NoDisplay=false
  '';
}