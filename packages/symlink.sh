sudo ln -s /usr/local/bin/ccache /usr/bin/ccache
sudo ln -s /usr/bin/python3 /usr/bin/python		
sudo ln -s /usr/bin/python3 /usr/bin/python2

# Disable parallel internet process for better compatible
sudo sysctl -w net.ipv4.tcp_window_scaling=0