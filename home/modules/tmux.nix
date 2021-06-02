{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    historyLimit = 5000;
    keyMode = "vi";
    terminal = "tmux-256color"; # Use `tmux` to enable italic support.
    prefix = "C-a";
    clock24 = true;

    extraConfig = ''
      set-option -g mouse on
      set-option -g escape-time 10 # Don't mess up when Esc followed by some keys.

      # Colors
      set-option -g status-style bg=colour234,fg=yellow
      set-option -g pane-active-border-style fg=pink
      set-option -g window-status-current-style bg=yellow,fg=black

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

      # Normal mode copy.
      bind-key -n DoubleClick1Pane select-pane \; copy-mode -M \; send-keys -X select-word \; \
        send-keys -X copy-pipe-no-clear "xsel -ip"
      bind-key -n TripleClick1Pane select-pane \; copy-mode -M \; send-keys -X select-line \; \
        send-keys -X copy-pipe-no-clear "xsel -ip"

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
