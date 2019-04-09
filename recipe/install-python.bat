mkdir build-python%PY_VER% && cd build-python%PY_VER%

set CFLAGS=
set CXXFLAGS=

cmake -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D ENABLE_FORTRAN=0 ^
      -D ENABLE_PYTHON=1 ^
      -D ENABLE_NETCDF=0 ^
      -D ENABLE_JPG=0 ^
      -D IEEE_LE=1 ^
      -D ENABLE_MEMFS=0 ^
      -D ENABLE_EXTRA_TESTS=OFF ^
      -D BUILD_SHARED_LIBS=ON ^
      %SRC_DIR%
if errorlevel 1 exit 1

type python3\setup.py

nmake
if errorlevel 1 exit 1

:: so tests can find eccodes.dll
set PATH=%PATH%;%SRC_DIR%\build\bin

nmake install
if errorlevel 1 exit 1
