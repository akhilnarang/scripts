echo "0.3. Install Optional package"
sudo aptitude install bc binutils-dev bison build-essential ca-certificates file flex 
sudo aptitude install ninja-build python3-dev texinfo u-boot-tools xz-utils
sudo aptitude install libelf-dev libssl-dev zlib1g-dev libncurses5
echo "###############################################"
echo "Done."
echo "###############################################"
echo "Run update to make sure it will not conflict"
sudo aptitude update && sudo aptitude upgrade
echo "Adding GitHub apt key and repository!"
sudo apt-get install software-properties-common -y
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
sudo apt-add-repository https://cli.github.com/packages
# Install lsb-core packages
sudo apt install lsb-core -y
echo "###############################################"
echo "Done."
echo "###############################################"