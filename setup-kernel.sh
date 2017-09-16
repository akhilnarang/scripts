#!/usr/bin/env bash

source ~/scripts/startupstuff.sh
[ -d "${BASEDIR}/kernel" ] || mkdir -pv "${BASEDIR}/kernel"
cd "${BASEDIR}/kernel";
hub clone kernel_oneplus_msm8996 oneplus3
hub clone AnyKernel2 -b oneplus3 anykernel/oneplus3
echo "Setup kernel source and anykernel, remember to add toolchain to ${BASEDIR}/kernel/toolchain/oneplus3 :)";
