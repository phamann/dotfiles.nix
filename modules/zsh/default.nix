{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = { enable = mkEnableOption "zsh"; };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      EDITOR = "nvim";
      PAGER = "less -FirSwX";
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
      GPG_TTY = "$(tty)";
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      shellAliases = {
        diff = "diff -u";
        tree = "tree --dirsfirst --noreport -ACF";
        grep = "grep --color=auto --exclude=tags --exclude-dir=.git";
        g = "nocorrect git";
        k = "nocorrect kubectl";
        r = "source ~/.zshrc";
        tmux = "tmux -2";
        l = "ls -l \${colorflag}";
        la = "ls -la \${colorflag}";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        cat = "bat --color=always --theme=ansi";
      };
      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreSpace = true;
        ignorePatterns = [
          "rm *"
          "pkill *"
        ];
      };
      profileExtra = ""; # TODO
      envExtra = ''
        export GPG_TTY=$(tty)
        export EDITOR="$(which nvim)"
        export GIT_EDITOR="nvim"
        export TERMINAL="$(which kitty)"
        export BROWSER="$(which firefox)"
        export FASTLY_CHEF_USERNAME="phamann"
        export GITHUB_USER="phamann"
        export GREP_COLOR='1;32'
        export CLICOLOR=1
        export GOPATH=$HOME/Projects
        export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
        export LSCOLORS=Gxfxcxdxbxegedabagacad
      '';
      sessionVariables = { }; # TODO
      loginExtra = ""; # TODO
      initExtraFirst = ""; # TODO
      initExtraBeforeCompInit = ''
        # man zshcontrib
        zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
        zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
        zstyle ':vcs_info:*' enable git #svn cvs

        # Enable completion caching, use rehash to clear
        zstyle ':completion::complete:*' use-cache on
        zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

        # Fallback to built in ls colors
        zstyle ':completion:*' list-colors ' '

        # Make the list prompt friendly
        zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'

        # Make the selection prompt friendly when there are a lot of choices
        zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

        # Add simple colors to kill
        zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

        # list of completers to use
        zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
        zstyle ':completion:*' menu select=1 _complete _ignored _approximate

        # match uppercase from lowercase
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

        # offer indexes before parameters in subscripts
        zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

        # formatting and messages
        zstyle ':completion:*' verbose yes
        zstyle ':completion:*:descriptions' format '%B%d%b'
        zstyle ':completion:*:messages' format '%d'
        zstyle ':completion:*:warnings' format 'No matches for: %d'
        zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
        zstyle ':completion:*' group-name ' '

        # ignore completion functions (until the _ignored completer)
        zstyle ':completion:*:functions' ignored-patterns '_*'
        zstyle ':completion:*:scp:*' tag-order files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
        zstyle ':completion:*:scp:*' group-order files all-files users hosts-domain hosts-host hosts-ipaddr
        zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
        zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host users hosts-ipaddr
        zstyle '*' single-ignored show

        # pasting with tabs doesn't perform completion
        zstyle ':completion:*' insert-tab pending
      '';
      initExtra = ''
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_FIND_NO_DUPS
        setopt HIST_IGNORE_SPACE
        setopt clobber
        setopt extendedglob
        setopt inc_append_history
        setopt share_history
        setopt interactive_comments
        setopt nobeep
        setopt prompt_subst
        source ${pkgs.grc}/etc/grc.zsh
        ${builtins.readFile ./functions.zsh}
      '';
    };
  };
}
