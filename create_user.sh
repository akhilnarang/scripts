export username="$1"
if [ -z $username ];
then
echo -e "Please enter a username"
read username
fi
sudo useradd "${username}" -m -s /bin/bash
passwd "${username}"
chage -d 0 "${username}"
