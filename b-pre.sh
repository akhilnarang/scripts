echo "Install pre package"
sudo aptitude install unzip zip cmake curl quota automake bzip2 dpkg-dev make -y
sudo aptitude install openjdk-11-jdk python-is-python3 python-kerberos python-networkx ruby-full rubygems sqlite3 -y
sudo aptitude install mysql-server ruby-mysql2 openssl -y
sudo aptitude install autoconf subversion pkg-config nodejsgit-all git-core redis-server ncurses-dev -y
sudo aptitude install clang clang-format clang-tidy clang-tools clangd lld lldb llvm  -y
sudo aptitude install reiserfsprogs pcmciautils nfs-common oprofile grub2-common mcelog dh-autoreconf gettext -y
sudo aptitude install gcc-multilib g++-multilib g++-aarch64-linux-gnu gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi bc -y
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

if [[ "$(command -v make)" ]]; then
    makeversion="$(make -v | head -1 | awk '{print $3}')"
    if [[ ${makeversion} != "${LATEST_MAKE_VERSION}" ]]; then
        echo "Installing make ${LATEST_MAKE_VERSION} instead of ${makeversion}"
        bash setup/make.sh "${LATEST_MAKE_VERSION}"
    fi
fi

echo "###############################################"
echo "Done."
echo "###############################################"
echo "Installing repo"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

echo "###############################################"
echo "Done."
echo "###############################################"
echo "Installing repo"
git clone --single-branch --depth=1 -b clang-13 https://github.com/LeCmnGend/proton-clang.git ~/tc/proton/clang-13

echo "###############################################"
echo "Done."
echo "###############################################"