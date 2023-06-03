{ pkgs, lib, config, ...}:
with lib; let
  cfg = config.modules.tmux;
  tokyo-night-tmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tokyo-night-tmux";
    rtpFilePath = "tokyo-night.tmux";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "janoamaral";
      repo = "tokyo-night-tmux";
      rev = "9bba871bd7af93026715b5b232fa3e9e3d9e7a01";
      sha256 = "sha256-R1t6E5Dd3Zq0MPdXnYyvU0+juC2/0pt6r+Hi3QeMKm4=";
    };
  };
in
{
  options.modules.tmux = { enable = mkEnableOption "tmux"; };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      newSession = true;
      terminal = "xterm-256color";
      plugins = [
        pkgs.tmuxPlugins.resurrect
        pkgs.tmuxPlugins.continuum
        pkgs.tmuxPlugins.sensible
        pkgs.tmuxPlugins.yank
      ];
      extraConfig = ''
        set -g mouse on
        bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e; send-keys -M'"
        bind -n C-k clear-history

        set -g default-terminal "screen-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set-option -g default-terminal "xterm-256color"
        set-option -ga terminal-overrides ',xterm-256color:Tc'

        # copy paste
        bind P paste-buffer
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-selection
        bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

        bind -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -sel clip -i"

        # Undercurl
        # https://github.com/folke/lsp-colors.nvim#making-undercurls-work-properly-in-tmux
        set -g default-terminal "screen-256color"
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

        # https://unix.stackexchange.com/a/320496
        # necessary to reload shell config changes
        set -g default-shell "${pkgs.zsh}/bin/zsh"

        set -g @resurrect-strategy-nvim 'session'
        set -g @continuum-restore 'on'

        run-shell ${tokyo-night-tmux}/share/tmux-plugins/tokyo-night-tmux/tokyo-night.tmux
      '';
    };
  };
}
