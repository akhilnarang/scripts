#!/usr/bin/env bash


lsmod | rg -q acpi_call && {
  echo "acpi_call already installed";
  exit 0;
}

git clone https://github.com/nix-community/acpi_call /tmp/acpi_call
make -C /tmp/acpi_call
sudo make -C /tmp/acpi_call install
sudo depmod -a
sudo modprobe acpi_call
rm -rf /tmp/acpi_call/
