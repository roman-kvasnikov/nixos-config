{ user, ... }:

{
  home.file = {
    ".config/user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="$HOME/"
      XDG_DOWNLOAD_DIR="$HOME/Downloads"
      XDG_TEMPLATES_DIR="$HOME/Templates"
      XDG_PUBLICSHARE_DIR="$HOME/"
      XDG_DOCUMENTS_DIR="$HOME/Documents"
      XDG_MUSIC_DIR="$HOME/"
      XDG_PICTURES_DIR="$HOME/Pictures"
      XDG_VIDEOS_DIR="$HOME/Videos"
    '';

    ".config/gtk-3.0/bookmarks".text = ''
      file:/// /
      file:///home/${user.name}/.local .local
      file:///home/${user.name}/.config .config
      file:///home/${user.name}/Documents
      file:///home/${user.name}/Downloads
    '';
  };
}
