{
  xdg.desktopEntries.discord = {
    version = "1.0";
    name = "Discord";
    comment = "Discord";
    exec = "uwsm app -- brave-browser --app=https://discord.com/app";
    terminal = false;
    type = "Application";
    icon = "discord";
    StartupNotify = true;
  };
}
