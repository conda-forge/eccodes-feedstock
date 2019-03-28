#!/usr/bin/env bash

set -e

export CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}:${PREFIX}:${BUILD_PREFIX}/${HOST}/sysroot/usr"

if [[ $(uname) == Linux ]]; then
    export CC=$(basename ${CC})
    export CXX=$(basename ${CXX})
    export FC=$(basename ${FC})
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
      -D ENABLE_JPG=1 \
      -D ENABLE_NETCDF=1 \
      -D ENABLE_PNG=1 \
      -D ENABLE_PYTHON=0 \
      -D ENABLE_FORTRAN=1 \
      -D ENABLE_AEC=1 \
      -D REPLACE_TPL_ABSOLUTE_PATHS=$REPLACE_TPL_ABSOLUTE_PATHS \
      $SRC_DIR

make -j $CPU_COUNT VERBOSE=1
export ECCODES_TEST_VERBOSE_OUTPUT=1
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib

ctest --output-on-failure -j $CPU_COUNT

make install

# Replace any leaked build env.
if [[ $(uname) == Linux ]]; then
    find $PREFIX/include -type f -print0 | xargs -0 sed -i "s@${BUILD_PREFIX}@${PREFIX}@g"
    find $PREFIX/lib/pkgconfig -type f -print0 | xargs -0 sed -i "s@${BUILD_PREFIX}@${PREFIX}@g"
    find $PREFIX/share/eccodes/cmake -type f -print0 | xargs -0 sed -i "s@${BUILD_PREFIX}@${PREFIX}@g"
fi
