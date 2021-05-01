{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    historyLimit = 5000;
    keyMode = "vi";
    terminal = "screen-256color"; # $TERM

    extraConfig = ''
      set -g prefix C-a
      set -g mouse on

      bind r source-file ~/.tmux.conf

      # Copy mode
      bind -n -T copy-mode-vi v send-keys -X begin-selection
      bind -n -T copy-mode-vi y send-keys -X copy-pipe "xsel -ib"

      # Split panes
      bind v split-window -h
      bind s split-window -v

      # Resize panes
      bind -r < resize-pane -L 5
      bind -r + resize-pane -D 5
      bind -r - resize-pane -U 5
      bind -r > resize-pane -R 5

      # Move between panes
      bind -r C-h select-pane -L
      bind -r C-j select-pane -D
      bind -r C-k select-pane -U
      bind -r C-l select-pane -R
    '';
  };
}
