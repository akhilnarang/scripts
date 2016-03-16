# username, user_ID
username="$1"
useradd "${username}"
mkhomedir_helper "${username}"
passwd "${username}"
chage -d 0 "${username}"
