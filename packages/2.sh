echo "0.2. Install Compiler package"
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add - # Fingerprint: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421
sudo aptitude install clang-12 clang-tools-12 clang-12-doc clang-format-12 python3-clang-12 clangd-12 clang-tidy-12
sudo aptitude install lldb-12 lld-12 
sudo aptitude install libfuzzer-12-dev libc++-12-dev libc++abi-12-dev  libomp-12-dev  libclc-12-dev libclang-common-12-dev libclang-12-dev libclang1-12
echo "###############################################"
echo "Done."
echo "###############################################"
echo "Run update to make sure it will not conflict"
sudo aptitude update && sudo aptitude upgrade