#!/usr/bin/env bash

# Git Configurations
git config --global credential.helper "cache --timeout=7200"

# Some git aliases
alias git='hub';
alias gs='git status';
alias gpul='git pull';
alias gf='git fetch';
alias grem='git remote';
alias gremv='git remote -v';
alias gpu='git push';
alias grev='git revert';
alias gcp='git cherry-pick';
alias gcpc='gcp --continue';
alias gr='git reset';
alias grh='gr --hard';
alias grs='gr --soft';
alias grb='git rebase';
alias grbi='grb --interactive';
alias grbc='grb --continue';
alias grbs='grb --skip';
alias gb='git bisect';

# SSH aliases
alias rr='ssh akhil@kaby'
alias aosip='ssh akhil@Illusion'
alias kronic='ssh kronic@Illusion'
alias jenkins='ssh root@buildbot'
alias setperf='echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
alias setsave='echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
alias path='echo ${PATH}'

# https://github.com/AdrianDC/android_development_shell_tools
# Has some useful stuff :)
ADCSCRIPT="${HOME}/android_development_shell_tools"
if [ -f "${ADCSCRIPT}/android_development_shell_tools.rc" ];
then
source "${ADCSCRIPT}/android_development_shell_tools.rc"
fi

if [[ "$(mount | grep raidzero)" ]]; then
    BASEDIR="/mnt/raidzero";
else
    BASEDIR="${HOME}";
fi


# Kernel Directory
export KERNELDIR="${BASEDIR}/kernel";

# Use ccache
export USE_CCACHE=1;
export CCACHE_ROOT="${BASEDIR}";
export CCACHE_DIR="${BASEDIR}/.ccache";

# Extend the default PATH a bit
export PATH=${BASEDIR}/bin:${BASEDIR}/android-studio/bin:${BASEDIR}/pidcat:${BASEDIR}/caddy:${BASEDIR}/AndroidSDK/platform-tools:${BASEDIR}/adb-sync:$PATH

# Set a custom path to install Android SDK into
export ANDROID_HOME=${BASEDIR}/AndroidSDK

# Set default editor to vim
export EDITOR="vim";

# Set timezone
export TZ="Asia/Kolkata";

# Colors
black='\e[0;30m'
blue='\e[0;34m'
green='\e[0;32m'
cyan='\e[0;36m'
red='\e[0;31m'
purple='\e[0;35m'
brown='\e[0;33m'
lightgray='\e[0;37m'
darkgray='\e[1;30m'
lightblue='\e[1;34m'
lightgreen='\e[1;32m'
lightcyan='\e[1;36m'
lightred='\e[1;31m'
lightpurple='\e[1;35m'
yellow='\e[1;33m'
white='\e[1;37m'
nc='\e[0m'


function syncc()
{
if [[ "$(python --version | awk '{print $2}' | awk -F '.' '{print $1}')" -ne 2 ]];
then
    if [[ "$(command -v 'virtualenv2')" ]]; then
        virtualenv2 "${BASEDIR}/virtualenv";
        source "${BASEDIR}/virtualenv/bin/activate";
    else
        echo "Please install 'virtualenv2', or make 'python' point to python2";
        exit 1;
    fi
fi

time repo sync --force-broken --force-sync --detach --no-clone-bundle --quiet --current-branch --no-tags $@

if [[ -d "${BASEDIR}/virtualenv" ]]; then
    echo -e "virtualenv detected, deactivating!";
    deactivate;
    rm -rf "${BASEDIR}/virtualenv";
fi

}

function transfer() {

zipname="$(echo $1 | awk -F '/' '{print $NF}')";
url="$(curl -# -T $1 https://transfer.sh)";
printf '\n';
echo -e "Download $zipname at $url";

}

function haste() {
a=$(cat);
curl -X POST -s -d "$a" http://haste.akhilnarang.me/documents | awk -F '"' '{print "http://haste.akhilnarang.me/"$4}';
}

function upinfo() #Not sure where this one is kanged from lol
{
echo -ne "${green}$(hostname) ${red}uptime is ${cyan} \t ";uptime | awk /'up/ {print $3,$4,$5,$6,$7,$8,$9,$10,$11}'
}

function onLogin() {

export KERNELDIR=~/kernel

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=auto
export GIT_PS1_SHOWCOLORHINTS=1

source ~/git-prompt.sh
unset PS1;
#PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ ';
PS1='| \w$(__git_ps1 " (%s)") |-> ';
clear;
echo -e "${LIGHTGRAY}";figlet -f slant "$(hostname)";
echo ""
echo -ne "${red}Today is:\t\t${cyan}" `date`; echo ""
echo -e "${red}Kernel Information: \t${cyan}" `uname -smr`
echo -ne "${cyan}";
upinfo;
echo ""
echo -e "Welcome to $(hostname), $(whoami)!\n";
fortune;
}
