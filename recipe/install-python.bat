mkdir build-python%PY_VER% && cd build-python%PY_VER%

set CFLAGS=
set CXXFLAGS=
set HAVE_STRING_H=1

cmake -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D ENABLE_FORTRAN=0 ^
      -D ENABLE_PYTHON=1 ^
      -D ENABLE_NETCDF=1 ^
      -D ENABLE_JPG=1 ^
      -D IEEE_LE=1 ^
      -D ENABLE_MEMFS=0 ^
      -D ENABLE_EXTRA_TESTS=OFF ^
      %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

:: so tests can find eccodes.dll
set PATH=%PATH%;%SRC_DIR%\build\bin

nmake install
if errorlevel 1 exit 1
