if [ "$(whoami)" == "root" ];
then
username="$1"
useradd "${username}"
mkhomedir_helper "${username}"
passwd "${username}"
chage -d 0 "${username}"
else
echo -e "Please run the script with root!"
fi
