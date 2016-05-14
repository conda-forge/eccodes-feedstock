#!/usr/bin/env bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
  # ctestarg="-E gts_ls"
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

src_dir="$(pwd)"
mkdir ../build
cd ../build
cmake $src_dir \
         -DCMAKE_INSTALL_PREFIX=$PREFIX \
         -DCMAKE_OSX_DEPLOYMENT_TARGET=10.10 \
         -DENABLE_JPG=1 \
         -DENABLE_NETCDF=1 \
         -DENABLE_PNG=1 \
         -DENABLE_PYTHON=0 \
         -DENABLE_FORTRAN=0

if [[ $(uname) == Darwin ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.10
fi
make
export ECCODES_TEST_VERBOSE_OUTPUT=1
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib
ctest #$ctestarg
make install
