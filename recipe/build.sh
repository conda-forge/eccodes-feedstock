#!/usr/bin/env bash


set -e # Abort on error.

export PING_SLEEP=30s
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BUILD_OUTPUT=$WORKDIR/build.out

if [[ "$c_compiler" == "gcc" ]]; then
  export PATH="${PATH}:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
fi

touch $BUILD_OUTPUT

dump_output() {
   echo Tailing the last 500 lines of output:
   tail -500 $BUILD_OUTPUT
}
error_handler() {
  echo ERROR: An error was encountered with the build.
  dump_output
  exit 1
}

# If an error occurs, run our error handler to output a tail of the build.
trap 'error_handler' ERR

# Set up a repeating loop to send some output to Travis.
bash -c "while true; do echo \$(date) - building ...; sleep $PING_SLEEP; done" &
PING_LOOP_PID=$!

## START BUILD
if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
  export FFLAGS="-isysroot $CONDA_BUILD_SYSROOT $FFLAGS"
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
         -DENABLE_JPG=1 \
         -DENABLE_NETCDF=1 \
         -DENABLE_PNG=0 \
         -DENABLE_PYTHON=0 \
         -DENABLE_FORTRAN=1 \
         -DENABLE_AEC=1

make -j $CPU_COUNT VERBOSE=1 >> $BUILD_OUTPUT 2>&1
export ECCODES_TEST_VERBOSE_OUTPUT=1
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib
if [[ $(uname) == Linux ]]; then
ctest -j $CPU_COUNT >> $BUILD_OUTPUT 2>&1
fi
make install >> $BUILD_OUTPUT 2>&1

# The build finished without returning an error so dump a tail of the output.
dump_output

# Nicely terminate the ping output loop.
kill $PING_LOOP_PID
