#!/usr/bin/env bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
  ctestarg="-E gts"
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir build_eccodes && cd build_eccodes
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_JPG=1 \
      -D ENABLE_NETCDF=1 \
      -D ENABLE_PNG=1 \
      -D ENABLE_PYTHON=0 \
      -D ENABLE_FORTRAN=1 \
      $SRC_DIR

make
export ECCODES_TEST_VERBOSE_OUTPUT=1
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib
ctest $ctestarg
make install
