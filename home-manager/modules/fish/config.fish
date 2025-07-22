set -g fish_greeting

# Aliases
alias ls = "eza -al --color=always --group-directories-first --icons";
alias la = "eza -a  --color=always --group-directories-first --icons";
alias ll = "eza -l  --color=always --group-directories-first --icons";
alias lt = "eza -aT --color=always --group-directories-first --icons";
alias cat = "bat --paging=never";

# Execute fastfetch only in interactive shells
if status is-interactive
    fastfetch
end
