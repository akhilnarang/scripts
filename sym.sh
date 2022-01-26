sudo ln -s /usr/local/bin/ccache /usr/bin/ccache
sudo ln -s ccache /usr/local/bin/clang
sudo ln -s ccache /usr/local/bin/clang++
sudo ln -s ccache /usr/local/bin/cc
sudo ln -s ccache /usr/local/bin/c++
sudo ln -s ccache /usr/local/bin/gcc
sudo ln -s ccache /usr/local/bin/g++
sudo ln -s /usr/bin/python3 /usr/bin/python		
sudo ln -s /usr/bin/python3 /usr/bin/python2
sudo ln -s /usr/lib32/libstdc++.so.6 /usr/lib32/libstdc++.so				
sudo ln -s /usr/lib32/libz.so.1 /usr/lib32/libz.so

# Disable parallel internet process for better compatible
sudo sysctl -w net.ipv4.tcp_window_scaling=0