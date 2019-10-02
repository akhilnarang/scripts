#!/usr/bin/env bash
[[ -f "${FILENAME:?}" ]] || exit
mkdir -pv ../downloads.resurrectionremix.com/"${DEVICE:?}"/
cp -v "${FILENAME}" ../downloads.resurrectionremix.com/"${DEVICE}"/
rm -v "${FILENAME}"
