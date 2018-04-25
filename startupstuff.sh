#!/usr/bin/env bash

source ~/scripts/functions;

if [[ "$(command -v hub)" ]]; then
    alias git='hub';
fi

# SSH aliases
alias rr='ssh akhil@rr.akhilnarang.me';
alias aosip='ssh akhil@aosiprom.com';
alias kronic='ssh kronic@aosiprom.com';
alias jenkins='ssh ubuntu@jenkins.akhilnarang.me';
alias bot='ssh bot@bot.akhilnarang.me'
alias downloads='ssh akhil@downloads.akhilnarang.me';

# Miscellaneous aliases
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

# Some PATH changes and stuff only for my laptop
if [[ "$(hostname)" == "randomness" ]]; then
    # Extend the default PATH a bit
    export PATH=${HOME}/bin:/opt/android-studio/bin:${HOME}/pidcat:/opt/android-sdk/platform-tools:${HOME}/adb-sync:$PATH;

    # Set a custom path for the Android SDK
    export ANDROID_HOME=${HOME}/Android/Sdk;
fi

# Set default editor to nano
export EDITOR="nano";

# Set timezone
export TZ="Asia/Kolkata";

# Colors
green='\e[0;32m';
cyan='\e[0;36m';
red='\e[0;31m';
lightgray='\e[0;37m';

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

