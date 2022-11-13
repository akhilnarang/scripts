echo "0.3. Install Optional package"
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo aptitude install bc binutils-dev bison build-essential ca-certificates file flex 
sudo aptitude install ninja-build python3-dev texinfo u-boot-tools xz-utils patchelf
sudo aptitude install libelf-dev libssl-dev zlib1g-dev libncurses5  bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev libsdl1.2-dev -y
sudo aptitude install libssl-dev -y
echo "###############################################"
echo "Done."

echo -e "Install GitHub CLI"
sudo apt-get install software-properties-common -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh


# Install lsb-core packages
sudo aptitude install lsb-core -y
echo "###############################################"
echo "Done."
echo "###############################################"