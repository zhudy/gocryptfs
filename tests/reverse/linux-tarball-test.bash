#!/bin/bash

set -eu

cd "$(dirname "$0")"
MD5="$PWD/../stress_tests/linux-3.0.md5sums"
MYNAME=$(basename "$0")

# Setup dirs
cd /tmp
wget -nv --show-progress -c https://www.kernel.org/pub/linux/kernel/v3.0/linux-3.0.tar.gz
WD=$(mktemp -d /tmp/$MYNAME.XXX)

# Cleanup trap
trap "set +u; cd /; fusermount -u -z $WD/c; fusermount -u -z $WD/b; rm -rf $WD" EXIT

cd $WD
mkdir a b c
echo "Extracting tarball"
tar -x -f /tmp/linux-3.0.tar.gz -C a
echo "Mounting a -> b -> c chain"
# Init "a"
gocryptfs -q -extpass="echo test" -reverse -init -scryptn=10 a
# Reverse-mount "a" on "b"
gocryptfs -q -extpass="echo test" -reverse  a b
# Forward-mount "b" on "c"
gocryptfs -q -extpass="echo test" b c
# Check md5 sums
cd c
echo "Checking md5 sums"
md5sum --status -c $MD5