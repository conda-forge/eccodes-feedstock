#!/usr/bin/env bash

set -e

if [[ "$c_compiler" == "gcc" ]]; then
  export PATH="${PATH}:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
fi

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
  export FFLAGS="-isysroot $CONDA_BUILD_SYSROOT $FFLAGS"
  export REPLACE_TPL_ABSOLUTE_PATHS=0
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
  export REPLACE_TPL_ABSOLUTE_PATHS=1
fi

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir ../build && cd ../build
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_BUILD_TYPE=Release \
      -D ENABLE_JPG=1 \
      -D ENABLE_NETCDF=1 \
      -D ENABLE_PNG=1 \
      -D ENABLE_PYTHON=0 \
      -D ENABLE_FORTRAN=1 \
      -D ENABLE_AEC=1 \
      -D REPLACE_TPL_ABSOLUTE_PATHS=$REPLACE_TPL_ABSOLUTE_PATHS \
      -D CMAKE_FIND_ROOT_PATH=$PREFIX \
      -D CMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
      -D CMAKE_PROGRAM_PATH=$BUILD_PREFIX \
      -D ECBUILD_LOG_LEVEL=DEBUG \
      $SRC_DIR

make -j $CPU_COUNT VERBOSE=1
export ECCODES_TEST_VERBOSE_OUTPUT=1
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib

ctest --output-on-failure -j $CPU_COUNT

make install
