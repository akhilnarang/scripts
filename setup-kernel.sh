#!/usr/bin/env bash

source ~/scripts/startupstuff.sh
[ -d "${BASEDIR}/kernel" ] || mkdir -pv "${BASEDIR}/kernel"
cd "${BASEDIR}/kernel";
hub clone kernel_oneplus_msm8996 oneplus3
cd oneplus3
hub remote add akhilnarang/DERP
hub remote add kernel/common https://android.googlesource.com/kernel/common
hub remote add caf https://source.codeaurora.org/quic/la/kernel/msm-3.18
hub remote add caf-mirror akhilnarang/kernel_msm-3.18
hub remote add linux-stable https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux-stable/
hub remote add linux-stable-rc https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux-stable-rc/
cd -
hub clone AnyKernel2 -b oneplus3 anykernel/oneplus3
echo "Setup kernel source and anykernel, remember to add toolchain to ${BASEDIR}/kernel/toolchain/oneplus3 :)";
