echo "Install pre package"
sudo aptitude install unzip zip cmake curl quota automake bzip2 dpkg-dev make -y
sudo aptitude install openjdk-11-jdk python-is-python3 ruby-full rubygems sqlite3 -y
sudo aptitude install mysql-server ruby-mysql2 openssl bc -y
sudo aptitude install autoconf subversion pkg-config git-core redis-server ncurses-dev -y
sudo aptitude install clang clang-format clang-tidy clang-tools clangd lld lldb llvm  -y
sudo aptitude install reiserfsprogs pcmciautils nfs-common oprofile grub2-common dh-autoreconf gettext -y
#sudo aptitude install gcc-multilib g++-multilib g++-aarch64-linux-gnu gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi -y
sudo aptitude install bison build-essential flex ninja-buildlld xsltproc -y
sudo aptitude install gnupg gperf imagemagick lzop pngcrush rsync schedtool squashfs-tools -y
sudo aptitude install libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev  -y
sudo aptitude install libssl-dev libncurses5 libxml2-utils libxml2 libsdl1.2-dev libncurses5-dev libncurses5 libwxgtk3.0-gtk3-dev -y
sudo aptitude install zlib1g-dev lib32z1-dev liblz4-tool lib32ncurses5-dev lib32readline-dev -y
sudo aptitude install libcurl4-gnutls-dev libexpat1-dev libz-dev libbz2-dev libbz2-1.0 libghc-bzlib-dev -y
sudo aptitude install optipng maven pwgen libswitch-perl policycoreutils minicom -y
sudo aptitude install libxml-sax-base-perl libxml-simple-perl libc6-dev x11proto-core-dev libx11-dev -y
sudo aptitude install lib32z-dev libgl1-mesa-dev libxslt1.1 libxslt1-dev libmysqlclient-dev -y
sudo aptitude install libreadline6 libreadline6-dev zlib1g libyaml-dev libxml2-dev libxslt-dev libgdbm-dev  -y
sudo aptitude install libcurl4-openssl-dev libmagickwand-dev libffi-dev libsqlite3-dev libpq-dev libreadline5 libtool -y
sudo aptitude install lsb-core -y

echo "###############################################"
echo "Done."
echo "###############################################"
echo "Run update to make sure it will not conflict"
sudo aptitude update && sudo aptitude upgrade -y

echo "###############################################"
echo "Done."
echo "###############################################"
echo -e "Setting up udev rules for adb!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo systemctl restart udev

echo "###############################################"
echo "Done."
echo "###############################################"
echo "Installing repo"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

echo "###############################################"
echo "Done."
echo "###############################################"
TC_DIR="$HOME/tc/proton/clang-13"
AK3_DIR="$HOME/tc/AnyKernel3"
echo "Installing clang tool chain"
if ! [ -d "$TC_DIR" ]; then
		echo "Proton clang not found! Cloning to $TC_DIR..."
		if ! git clone --single-branch --depth 1 -b clang-13 https://github.com/LeCmnGend/proton-clang.git $TC_DIR; then
				echo "Cloning failed! Aborting..."
				exit 1
		fi
fi

if ! [ -d "$AK3_DIR" ]; then
				echo "$AK3_DIR not found! Cloning to $AK3_DIR..."
				if ! git clone -q --single-branch --depth 1 -b 11.0 https://github.com/lecmngend/AnyKernel3 $AK3_DIR; then
						echo "Cloning failed! Aborting..."
						exit 1
				fi
		fi

echo "###############################################"
echo "Done."
echo "###############################################"
echo "Installing Build environment"
bash setup/install_android_sdk.sh
