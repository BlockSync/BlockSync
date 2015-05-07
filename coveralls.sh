#!/bin/bash

source xcenv.sh
declare -r DIR_BUILD="${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}/"
./xcode-coveralls --verbose --exclude "Example" --token GSk2EukcT1Fh84ii91H9p7pVPu9GehqAc "${DIR_BUILD}"
