{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = mkEnableOption "zsh";
    keychain = mkEnableOption {
      type = types.bool;
      default = true;
    };
  };
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
      dotDir = ".config/zsh";
      autosuggestion = {
        enable = true;
      };
      shellAliases = {
        diff = "diff -u";
        tree = "tree --dirsfirst --noreport -ACF";
        grep = "grep --color=auto --exclude=tags --exclude-dir=.git";
        g = "nocorrect git";
        k = "nocorrect kubectl";
        r = "source ~/.zshenv";
        tmux = "tmux -2";
        l = "ls -l \${colorflag}";
        la = "ls -la \${colorflag}";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        cat = "bat --color=always";
        yoda = "ssh phamann@192.168.1.40";
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
      historySubstringSearch = {
        enable = true;
      };
      profileExtra = ""; # TODO
      envExtra = ''
        export GPG_TTY=$(tty)
        export EDITOR="$(which nvim)"
        export GIT_EDITOR="nvim"
        export BROWSER="$(which firefox)"
        export FASTLY_CHEF_USERNAME="phamann"
        export GITHUB_USER="phamann"
        export GREP_COLOR='1;32'
        export CLICOLOR=1
        export GOPATH=$HOME/Projects
        export LSCOLORS=Gxfxcxdxbxegedabagacad
        export INFRA_SKIP_VERSION_CHECK=true
        export PATH=$PATH:$HOME/.cargo/bin
        export JAVA_HOME=${pkgs.jdk17}
        export PATH=$JAVA_HOME/bin:$PATH
        export PATH=$GOPATH/bin:$PATH
        export PATH=$HOME/bin:$PATH
      '';
      sessionVariables = { }; # TODO
      loginExtra = ""; # TODO
      initExtraFirst = ""; # TODO
      initExtraBeforeCompInit = ''
        if [[ -z "$ZELLIJ" ]] && [[ "$(uname -s)" = "Darwin" ]]; then
            zellij attach -c work

            if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
                exit
            fi
        fi
        # ===== Basics
        setopt no_beep # don't beep on error
        setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)

        # ===== Changing Directories
        setopt auto_cd # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
        setopt cdablevarS # if argument to cd is the name of a parameter whose value is a valid directory, it will become the current directory
        setopt pushd_ignore_dups # don't push multiple copies of the same directory onto the directory stack

        # ===== Expansion and Globbing
        setopt extended_glob # treat #, ~, and ^ as part of patterns for filename generation

        # ===== History
        setopt append_history # Allow multiple terminal sessions to all append to one zsh command history
        setopt extended_history # save timestamp of command and duration
        setopt inc_append_history # Add comamnds as they are typed, don't wait until shell exit
        setopt hist_expire_dups_first # when trimming history, lose oldest duplicates first
        setopt hist_ignore_dups # Do not write events to history that are duplicates of previous events
        setopt hist_ignore_space # remove command line from history list when first character on the line is a space
        setopt hist_find_no_dups # When searching history don't display results already cycled through twice
        setopt hist_reduce_blanks # Remove extra blanks from each command line being added to history
        setopt hist_verify # don't execute, just expand history
        setopt share_history # imports new commands and appends typed commands to history

        # ===== Completion
        setopt always_to_end # When completing from the middle of a word, move the cursor to the end of the word
        setopt auto_menu # show completion menu on successive tab press. needs unsetop menu_complete to work
        setopt auto_name_dirs # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
        setopt complete_in_word # Allow completion from within a word/phrase
        setopt complete_aliases

        unsetopt menu_complete # do not autoselect the first completion entry

        # ===== Correction
        setopt correct # spelling correction for commands
        setopt correctall # spelling correction for arguments
        CORRECT_IGNORE='st,test'

        # ===== Prompt
        setopt prompt_subst # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
        setopt transient_rprompt # only show the rprompt on the current prompt

        # ===== Scripts and Functions
        setopt multios # perform implicit tees or cats when multiple redirections are attempted

        zle -N newtab

        bindkey '^[^[[D' backward-word
        bindkey '^[^[[C' forward-word
        bindkey '^[[5D' beginning-of-line
        bindkey '^[[5C' end-of-line
        bindkey '^[[3~' delete-char
        bindkey '^[^N' newtab
        bindkey '^?' backward-delete-char
      '';

      initExtra = ''
        zmodload -i zsh/complist

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

        eval "$(fastly --completion-script-zsh)"

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

        # Load functions
        ${builtins.readFile ./functions.zsh}

        zellij_tab_name_update
        chpwd_functions+=(zellij_tab_name_update)

        # Load tools
        source ${pkgs.grc}/etc/grc.zsh
        eval "$(zoxide init zsh)"
        ${if cfg.keychain then "eval $(keychain --eval --quiet ~/.ssh/id_rsa)" else ""}
        eval "$(direnv hook zsh)"
        eval "$(starship init zsh)"
      '';
    };
  };
}
