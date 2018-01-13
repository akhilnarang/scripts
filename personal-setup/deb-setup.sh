sudo install utils/hub /usr/local/bin/hub
git config --global user.name "Akhil Narang"
git config --global user.email "akhilnarang.1999@gmail.com"
git config --global credential.helper "cache --timeout=7200"
echo "" >> ~/.bashrc
echo "source ~/scripts/startupstuff.sh" >> ~/.bashrc
echo "onLogin" >> ~/.bashrc
sudo apt install figlet fortune -y

