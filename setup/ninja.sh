cd /tmp;
git clone git://github.com/akhilnarang/ninja.git;
cd ninja;
./configure.py --bootstrap;
sudo install ./ninja /usr/local/bin/ninja;
rm -rf ${PWD};
cd -;
