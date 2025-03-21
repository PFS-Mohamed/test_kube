# /etc/bashrc

# System wide functions and aliases
# Environment stuff goes in /etc/profile

# It's NOT a good idea to change this file unless you know what you
# are doing. It's much better to create a custom.sh shell script in
# /etc/profile.d/ to make custom changes to your environment, as this
# will prevent the need for merging in future updates.

# Prevent doublesourcing
if [ -z "$BASHRCSOURCED" ]; then
  BASHRCSOURCED="Y"

  # are we an interactive shell?
  if [ "$PS1" ]; then
    if [ -z "$PROMPT_COMMAND" ]; then
      case $TERM in
      xterm*|vte*)
        if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
        elif [ "${VTE_VERSION:-0}" -ge 3405 ]; then
            PROMPT_COMMAND="__vte_prompt_command"
        else
            PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        fi
        ;;
      screen*)
        if [ -e /etc/sysconfig/bash-prompt-screen ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
        else
            PROMPT_COMMAND='printf "\033k%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        fi
        ;;
      *)
        [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
        ;;
      esac
    fi
    # Turn on parallel history
    shopt -s histappend
    history -a
    # Turn on checkwinsize
    shopt -s checkwinsize
    [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
    # You might want to have e.g. tty in prompt (e.g. more virtual machines)
    # and console windows
    # If you want to do so, just add e.g.
    # if [ "$PS1" ]; then
    #   PS1="[\u@\h:\l \W]\\$ "
    # fi
    # to your custom modification shell script in /etc/profile.d/ directory
  fi

  if ! shopt -q login_shell ; then # We're not a login shell
    # Need to redefine pathmunge, it gets undefined at the end of /etc/profile
    pathmunge () {
        case ":${PATH}:" in
            *:"$1":*)
                ;;
            *)
                if [ "$2" = "after" ] ; then
                    PATH=$PATH:$1
                else
                    PATH=$1:$PATH
                fi
        esac
    }

    # By default, we want umask to get set. This sets it for non-login shell.
    # Current threshold for system reserved uid/gids is 200
    # You could check uidgid reservation validity in
    # /usr/share/doc/setup-*/uidgid file
    if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
       umask 002
    else
       umask 022
    fi

    SHELL=/bin/bash
    # Only display echos from profile.d scripts if we are no login shell
    # and interactive - otherwise just process them to set envvars
    for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
            if [ "$PS1" ]; then
                . "$i"
            else
                . "$i" >/dev/null
            fi
        fi
    done

    unset i
    unset -f pathmunge
  fi

fi
# vim:ts=4:sw=4


# some more ls aliases
alias ls='ls --color'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias tailf='tail -f'
alias dstat='dstat -t -l -c -p -m -s -d -n -i -r -y --fs'
alias systemctl='systemctl-shortcut'
alias btop='btop --utf-force'
alias ccze='ccze -o nolookups'



# Par sécurité
umask 027

# Terminal
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Blanc
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;30m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Noir
#PS1='${debian_chroot:+($debian_chroot)}\[\033[07;30m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Blanc sur fond Noir
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Rouge
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Vert
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Jaune
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Bleu
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;35m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Violet
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;36m\]\u@stack-builder-\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Cyan
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;37m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Blanc
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;35m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Violet
#PS1='${debian_chroot:+($debian_chroot)}\[\033[07;35m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Noir sur fond violet
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Bleu
#PS1='[\[\033[01;32m\]PROD\[\033[00m\]] ${debian_chroot:+($debian_chroot)}\[\033[07;33m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ ' # Noir sur fond Bleu
#PS1='[\[\033[01;31m\]REPLIQUANT\[\033[00m\]] ${debian_chroot:+($debian_chroot)}\[\033[07;33m\]\u@\h\[\033[00m\] : \[\033[01;30m\]\w \[\033[00m\]\$ '
# Noir sur fond Bleu
