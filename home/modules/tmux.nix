{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    historyLimit = 5000;
    keyMode = "vi";
    terminal = "tmux-256color"; # Fix italic and true color support.
    prefix = "C-a";
    clock24 = true;

    extraConfig = ''
      set-option -g mouse on
      set-option -g escape-time 10 # Don't mess up when Esc followed by some keys.

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
      set-option -g status-style bg=black,fg=yellow
      set-option -g window-status-current-style bg=yellow,fg=black
      set-option -g message-style bg=black,fg=yellow
      set-option -g message-command-style bg=yellow,fg=black
      set-option -g pane-active-border-style fg=magenta

      # Custom window title
      set-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}:#{?#{!=:#{window_panes},1},#{window_panes}:,}#{pane_current_command}'

      # Reload.
      bind-key r source-file ~/.config/tmux/tmux.conf \; \
        display-message "source-file done"

      # Split panes.
      bind-key v split-window -h -c "#{pane_current_path}"
      bind-key s split-window -v -c "#{pane_current_path}"

      # Resize panes.
      bind-key -r H resize-pane -L 5
      bind-key -r J resize-pane -D 5
      bind-key -r K resize-pane -U 5
      bind-key -r L resize-pane -R 5

      # Move between panes.
      bind-key -r C-h select-pane -L
      bind-key -r C-j select-pane -D
      bind-key -r C-k select-pane -U
      bind-key -r C-l select-pane -R

      # Copy & paste.
      set-option -s set-clipboard off
      # Copy mode.
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi V send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xsel -ib"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-no-clear "xsel -ip"
      bind-key -T copy-mode-vi DoubleClick1Pane send-keys -X select-word \; \
        send-keys -X copy-pipe-no-clear "xsel -ip"
      bind-key -T copy-mode-vi TripleClick1Pane send-keys -X select-line \; \
        send-keys -X copy-pipe-no-clear "xsel -ip"

      # Normal mode copy, only if the inner program doesn't have mouse enabled.
      bind-key -n DoubleClick1Pane if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" "send -M" {
        copy-mode -e
        send-keys -X select-word
        send-keys -X copy-pipe-no-clear "xsel -ip"
      }
      bind-key -n TripleClick1Pane if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" "send -M" {
        copy-mode -e
        send-keys -X select-line
        send-keys -X copy-pipe-no-clear "xsel -ip"
      }

      # Copy & normal mode paste.
      bind-key -T copy-mode-vi MouseDown2Pane send-keys -X cancel \; \
        run "tmux set-buffer -b primary_selection \"$(xsel -op)\"; tmux paste-buffer -b primary_selection"
      bind-key -n MouseDown2Pane select-pane \; \
        run "tmux set-buffer -b primary_selection \"$(xsel -op)\"; tmux paste-buffer -b primary_selection"

      # Clear some default bindings.
      unbind-key up
      unbind-key down
      unbind-key left
      unbind-key right
    '';
  };
}
