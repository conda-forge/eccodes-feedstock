#!/usr/bin/env bash

set -e

if [[ "$c_compiler" == "gcc" ]]; then
  export PATH="${PATH}:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
fi

if [[ $(uname) == Linux ]]; then
    export CC=$(basename ${CC})
    export CXX=$(basename ${CXX})
    export FC=$(basename ${FC})
fi

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
  export FFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} ${FFLAGS}"
  export REPLACE_TPL_ABSOLUTE_PATHS=0
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
  export REPLACE_TPL_ABSOLUTE_PATHS=1
fi

export PYTHON="${PYTHON}"
export PYTHON_LDFLAGS="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
export CFLAGS="${CFLAGS} -fPIC -I${PREFIX}/include"

mkdir ../build-python${PY_VER} && cd ../build-python${PY_VER}
cmake -D CMAKE_INSTALL_PREFIX=${PREFIX} \
      -D ENABLE_JPG=1 \
      -D ENABLE_NETCDF=1 \
      -D ENABLE_PNG=1 \
      -D ENABLE_PYTHON=1 \
      -D ENABLE_FORTRAN=0 \
      -D ENABLE_AEC=1 \
      ${SRC_DIR}

make -j $CPU_COUNT VERBOSE=1
make install
