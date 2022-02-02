bash packages/1.sh
bash packages/2.sh
bash packages/3.sh
echo "###############################################"
echo "Done."
echo "###############################################"
echo "Run update to make sure it will not conflict"
sudo aptitude update && sudo aptitude upgrade -y

echo "###############################################"
echo "Done."
echo "###############################################"
echo -e "Setting up udev rules for adb!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo service udev restart

echo "###############################################"
echo "Done."
echo "###############################################"
echo "Installing repo"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo
echo "###############################################"
echo "Done."
echo "###############################################"
echo "Installing proton clang 14"
TC_DIR="$HOME/tc/proton/clang-14"
if ! [ -d "$TC_DIR" ]; then
		echo "Proton clang not found! Cloning to $TC_DIR..."
		if ! git clone --single-branch --depth=1 -b clang-14 https://gitlab.com/LeCmnGend/proton-clang $TC_DIR; then
				echo "Cloning failed! Aborting..."
				exit 1
		fi
fi

echo "###############################################"
echo "Done."
echo "###############################################"
echo "Installing AnyKernel3"
if ! [ -d "$AK3_DIR" ]; then
				echo "$AK3_DIR not found! Cloning to $AK3_DIR..."
				if ! git clone -q --single-branch --depth=1 -b ginkgo https://github.com/lecmngend/AnyKernel3 $AK3_DIR; then
						echo "Cloning failed! Aborting..."
						exit 1
				fi
		fi

echo "###############################################"
echo "Done."
echo "###############################################"
echo "Installing Build environment"
bash setup/install_android_sdk.sh
echo "###############################################"
echo "Done."
echo "###############################################"


