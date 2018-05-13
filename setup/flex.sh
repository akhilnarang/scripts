cd /tmp;
git clone git://github.com/akhilnarang/flex.git;
cd flex;
./autogen.sh;
./configure;
make -j$(nproc);
sudo make install;
rm -rf ${PWD};
cd -;
