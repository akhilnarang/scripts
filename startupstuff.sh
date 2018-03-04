#!/usr/bin/env bash

if [[ "$(command -v hub)" ]]; then
    alias git='hub';
fi

# Some git aliases
alias gs='git status';
alias gpul='git pull';
alias gf='git fetch';
alias grem='git remote';
alias gremv='git remote -v';
alias gpu='git push';
alias gpf='gpu -f'
alias gpfu='gpu -fu';
alias grev='git revert';
alias gcp='git cherry-pick';
alias gcpc='gcp --continue';
alias gcpa='gcp --abort';
alias gr='git reset';
alias grh='gr --hard';
alias grs='gr --soft';
alias grb='git rebase';
alias grbi='grb --interactive';
alias grbc='grb --continue';
alias grbs='grb --skip';
alias grba='grb --abort';
alias gb='git bisect';
alias gd='git diff';
alias gc='git commit';

# SSH aliases
alias rr='ssh akhil@rr.akhilnarang.me';
alias aosip='ssh akhil@aosiprom.com';
alias kronic='ssh kronic@aosiprom.com';
alias jenkins='ssh ubuntu@jenkins.akhilnarang.me';
alias bot='ssh bot@bot.akhilnarang.me'

# Misc
alias setperf='echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor';
alias setsave='echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor';
alias path='echo ${PATH}';
alias stopjack='jack-admin stop-server';

# https://github.com/AdrianDC/android_development_shell_tools
# Has some useful stuff :)
ADCSCRIPT="${HOME}/android_development_shell_tools";
if [[ -f "${ADCSCRIPT}/android_development_shell_tools.rc" ]]; then
    source "${ADCSCRIPT}/android_development_shell_tools.rc";
fi

# Kernel Directory
export KERNELDIR="${HOME}/kernel";

# Use ccache
export USE_CCACHE=1;
if [[ -z "${CCACHE_DIR}" ]]; then
    export CCACHE_DIR="${HOME}/.ccache";
fi

# Extend the default PATH a bit
export PATH=${HOME}/bin:/opt/android-studio/bin:${HOME}/pidcat:${HOME}/Android/Sdk/platform-tools:${HOME}/adb-sync:$PATH;

# Set a custom path for the Android SDK
export ANDROID_HOME=${HOME}/Android/Sdk;

# Set default editor to nano
export EDITOR="nano";

# Set timezone
export TZ="Asia/Kolkata";

# Colors
green='\e[0;32m';
cyan='\e[0;36m';
red='\e[0;31m';
lightgray='\e[0;37m';


function run_virtualenv() {
    PYV=$(python -c "import sys;t='{v[0]}'.format(v=list(sys.version_info[:1]));sys.stdout.write(t)");
    if [[ "${PYV}" == "3" ]]; then
        if [[ "$(command -v 'virtualenv2')" ]]; then
            if [[ ! -d "${HOME}/virtualenv" ]]; then
                virtualenv2 "${HOME}/virtualenv";
            fi
            source "${HOME}/virtualenv/bin/activate";
        else
            echo "Please install 'virtualenv2', or make 'python' point to python2";
        fi
    fi

    "$@";

    if [[ -d "${HOME}/virtualenv" ]]; then
        echo -e "virtualenv detected, deactivating!";
        deactivate;
    fi
}

function syncc() {
    time run_virtualenv repo sync --force-broken --force-sync --detach --no-clone-bundle --quiet --current-branch --no-tags "$@";
}

function transfer() {
    zipname=$(echo "$1" | awk -F '/' '{print $NF}')
    url=$(curl -# -T "$1" https://transfer.sh);
    printf '\n';
    echo -e "Download $zipname at $url";
}

function haste() {
    a=$(cat);
    curl -X POST -s -d "$a" http://haste.akhilnarang.me/documents | awk -F '"' '{print "http://haste.akhilnarang.me/"$4}';
}

# Not sure where this one is kanged from lol
function upinfo() {
    echo -ne "${green}$(hostname) ${red}uptime is ${cyan} \\t ";uptime | awk /'up/ {print $3,$4,$5,$6,$7,$8,$9,$10,$11}';
}

function onLogin() {
    export GIT_PS1_SHOWDIRTYSTATE=1;
    export GIT_PS1_SHOWSTASHSTATE=1;
    export GIT_PS1_SHOWUNTRACKEDFILES=1;
    export GIT_PS1_SHOWUPSTREAM=auto;
    export GIT_PS1_SHOWCOLORHINTS=1;
    unset PS1;
    #PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ ';
    if [[ -f "${HOME}/git-prompt.sh" ]]; then
        source ~/git-prompt.sh
        PS1='| \h (\w)$(__git_ps1 " {%s}") |-> ';
    else
        PS1='| \h (\w) |-> ';
    fi
    clear;
    HOST=$(hostname);
    if [[ ${#HOST} -lt 14 ]]; then
        echo -e "${lightgray}";figlet -c "$(hostname)";
    fi
    echo ""
    echo -ne "${red}Today is:\\t\\t${cyan} $(date)";
    echo ""
    echo -e "${red}Kernel Information: \\t${cyan} $(uname -smr)"
    echo -ne "${cyan}";
    upinfo;
    echo "";
    echo -e "Welcome to $(hostname), $(whoami)!";
    echo -e;
    fortune;
}

function venv() {
    virtualenv2 /tmp/venv;
    source /tmp/venv/bin/activate;
}

function rmvenv() {
    deactivate;
    rm -rf /tmp/venv/bin/activate;
}
