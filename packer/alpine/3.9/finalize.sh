#!/bin/sh

set -x

# Zeroize
dd if=/dev/zero of=/myZeroFile
rm -rf /myZeroFile
sync
