{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 1;
    historyLimit = 100000;
    keyMode = "vi";
    prefix = "C-a";
    terminal = "tmux-256color"; # Fix wierd behaviors for dim colors.

    # tmux
    extraConfig = ''
      set -g mouse on
      set -g set-clipboard on
      set -g word-separators " ,\"'[](){}<>=:@"

      set -sa terminal-overrides "alacritty:Tc"
      # Hyperlinks.
      set -sa terminal-overrides '*:Hls=\E]8;id=%p1%s;%p2%s\E\\:Hlr=\E]8;;\E\\'
      # SGR 53 (Overline).
      set -sa terminal-overrides '*:Smol=\E[53m'
      # Styled underlines.
      set -sa terminal-overrides '*:Smulx=\E[4::%p1%dm'
      # Underline colors.
      set -sa terminal-overrides '*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # Colors
      set -g status-style fg=green
      set -g window-status-current-style reverse

      # Custom window title.
      set -g automatic-rename on
      set -g automatic-rename-format '#{b:pane_current_path}#{?#{!=:#{pane_current_command},zsh},:#{pane_current_command},}'
      set -g status-interval 1

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

      # Copy mode behaviors.
      # Ref: https://github.com/tmux/tmux/issues/140#issuecomment-474341833
      # Don't exit after selection.
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-no-clear
      bind-key -T copy-mode-vi DoubleClick1Pane send-keys -X select-word \; send-keys -X copy-selection-no-clear
      bind-key -T copy-mode-vi TripleClick1Pane send-keys -X select-line \; send-keys -X copy-selection-no-clear
      # Clear selection on single-click.
      bind-key -T copy-mode-vi MouseDown1Pane select-pane \; send-keys -X clear-selection
      # Quick enter and leave.
      bind-key -n DoubleClick3Pane copy-mode -M \; send-keys -X select-word \; send-keys -X copy-selection-no-clear
      bind-key -n TripleClick3Pane copy-mode -M \; send-keys -X select-line \; send-keys -X copy-selection-no-clear
      bind-key -T copy-mode-vi MouseDown3Pane send-keys -X cancel
    '';
  };
}
