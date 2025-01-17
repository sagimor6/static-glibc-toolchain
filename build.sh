#!/bin/sh

BASE_DIR="$(dirname "${BASE_SOURCE:-$0}")"
BASE_DIR="$(cd "${BASE_DIR}" &> /dev/null && pwd)"
BUILD_DIR="${BUILD_DIR:-${BASE_DIR}/build2}"
BUILD_DIR=$(realpath "${BUILD_DIR}")
OUTPUT_DIR="${OUTPUT_DIR:-${BASE_DIR}/output2}"
OUTPUT_DIR=$(realpath "${OUTPUT_DIR}")

CTNG_URL="https://github.com/crosstool-ng/crosstool-ng/releases/download/crosstool-ng-1.26.0/crosstool-ng-1.26.0.tar.xz"
TAR_DECOMP_FLAG=

rm -rf ${BUILD_DIR}
rm -rf ${OUTPUT_DIR}

mkdir ${BUILD_DIR}
cd ${BUILD_DIR}

mkdir tars
cd tars
wget ${CTNG_URL}
cd ..

mkdir src
cd src

mkdir ctng
cd ctng
tar -x${TAR_DECOMP_FLAG}f ../../tars/crosstool-ng-*.tar.*

cd * # inside ct-ng

./configure --enable-local

make -j

cp "${BASE_DIR}/.config" .

./ct-ng upgradeconfig

NPROC=$(nproc)
NPROC=${NPROC:-0}

CT_ONLY_EXTRACT=y CT_LOCAL_TARBALLS_DIR="${BUILD_DIR}/tars" ./ct-ng build.${NPROC}

sed -r -i 's/^#define(\s+\w+\s+)"\/etc\/nsswitch\.conf"\s*$/#ifdef SHARED\n\0\n#else\n#define\1""\n#endif/g' ./.build/src/glibc-*/resolv/netdb.h

CT_PREFIX=${OUTPUT_DIR} CT_LOCAL_TARBALLS_DIR="${BUILD_DIR}/tars" ./ct-ng build.${NPROC}






