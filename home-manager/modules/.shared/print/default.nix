{pkgs, ...}: (pkgs.writeShellScriptBin "print" (builtins.readFile ./print.sh))
