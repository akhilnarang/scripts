echo "0.2. Install Compiler package"
#sudo aptitude install clang-12 clang-tools-12 clang-12-doc clang-format-12 python3-clang-12 clangd-12 clang-tidy-12
#sudo aptitude install lldb-12 lld-12 
#sudo aptitude install libfuzzer-12-dev libc++-12-dev libc++abi-12-dev  libomp-12-dev  libclc-12-dev libclang-common-12-dev libclang-12-dev libclang1-12

LLVM_VER=clang+llvm-13.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz
if [ ! -d "/root/tmp/clang13" ] && [ ! -f "/root/tmp/clang13/$LLVM_VER" ] ; then
	wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add - # Fingerprint: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421
	mkdir -p /root/tmp/clang13
	cd /root/tmp/clang13
	wget https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/$LLVM_VER
	sudo tar -C /usr/local -xvf $LLVM_VER --strip 1
fi
echo "###############################################"
echo "Done."

