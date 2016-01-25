# username, user_ID
useradd "$1"
usermod -g builders "$1"
mkhomedir_helper "$1"
passwd "$1"
