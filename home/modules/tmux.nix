{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    historyLimit = 5000;
    keyMode = "vi";
    terminal = "tmux-256color"; # Fix italic and true color support.
    prefix = "C-a";
    clock24 = true;

    # tmux
    extraConfig = ''
      set -g mouse on
      set -g escape-time 1 # Don't mess up when Esc followed by some keys.
      set -g set-clipboard on

      # Fixups
      # For true colors
      # https://gist.github.com/XVilka/8346728
      set -sa terminal-overrides "alacritty:Tc"
      set -sa terminal-overrides "xterm-256color:Tc"
      # hyperlink (experimental)
      set -sa terminal-overrides '*:Hls=\E]8;id=%p1%s;%p2%s\E\\:Hlr=\E]8;;\E\\'
      # SGR 53 (overline)
      set -sa terminal-overrides '*:Smol=\E[53m'
      # styled underscore
      set -sa terminal-overrides '*:Smulx=\E[4::%p1%dm'
      # underscore colors
      set -sa terminal-overrides '*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # Colors
      set -g status-style fg=yellow
      set -g window-status-current-style bg=yellow,fg=black
      set -g message-style bg=black,fg=yellow
      set -g message-command-style bg=yellow,fg=black
      set -g pane-active-border-style fg=magenta

      # Custom window title
      set -g automatic-rename on
      set -g automatic-rename-format '#{b:pane_current_path}:#{?#{!=:#{window_panes},1},#{window_panes}:,}#{pane_current_command}'

      # Reload.
      bind r source-file ~/.config/tmux/tmux.conf \; \
        display-message "source-file done"

      # Split panes.
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"

      # Resize panes.
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Move between panes.
      bind -r C-h select-pane -L
      bind -r C-j select-pane -D
      bind -r C-k select-pane -U
      bind -r C-l select-pane -R

      # Clear some default bindings.
      unbind up
      unbind down
      unbind left
      unbind right
    '';
  };
}
