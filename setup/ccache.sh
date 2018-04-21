cd /tmp;
git clone git://github.com/akhilnarang/ccache.git;
cd ccache;
./autogen.sh;
./configure;
make -j$(nproc);
sudo make install;
rm -rf ${PWD};
cd -;
