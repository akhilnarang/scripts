#!/usr/bin/env sh

git config --global user.name "Akhil Narang"
git config --global user.email "akhilnarang.1999@gmail.com"
git config --global credential.helper "cache --timeout=7200"
printf '\n' | tee -a ~/.bashrc
echo "source ~/scripts/functions" >> ~/.bashrc
echo "onLogin" >> ~/.bashrc
yaourt -S figlet fortune-mod hub byobu --noconfirm
