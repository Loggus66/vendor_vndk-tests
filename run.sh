#!/bin/bash

set -ex

sext=""
if [ -f "$2"/system/system_ext/etc/selinux/system_ext_sepolicy.cil ];then
    sext="$2"/system/system_ext/etc/selinux/system_ext_sepolicy.cil
fi

HOST_OS=$(uname -s)
TARGET_INCLUDE=linux
if [ "$HOST_OS" == "Darwin" ]; then
  TARGET_INCLUDE=darwin
fi

t="$(mktemp)"
for vndk in 26 27;do
	for src in $(find "$1"/sepolicies/$vndk/ -name \*.cil);do
		./out/host/${TARGET_INCLUDE}-x86/bin/secilc "$2"/system/etc/selinux/plat_sepolicy.cil -o "$t" -M true -G -N -c 30 "$2"/system/etc/selinux/mapping/${vndk}.0.cil $sext "$src"
		./out/host/${TARGET_INCLUDE}-x86/bin/checkpolicy -M -bC -o /dev/null "$t"
		rm -f "$t"
	done
done
