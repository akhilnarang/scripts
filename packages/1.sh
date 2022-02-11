echo "0.1. Install requirement package"
echo "###############################################"
sudo aptitude install unzip zip cmake curl make git-core git wget tar  zstd
sudo aptitude install build-essential flex ninja-build python-is-python3 ruby-full sqlite3 openjdk-11-jdk
echo "###############################################"
echo "Done."
echo "###############################################"
echo "Run update to make sure it will not conflict"
sudo aptitude update && sudo aptitude upgrade