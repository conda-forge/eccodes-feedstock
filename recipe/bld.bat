mkdir %SRC_DIR%\build
cd %SRC_DIR%\build

set PYTHON=

:: Shared.
cmake -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D ENABLE_JPG=1 ^
      -D ENABLE_NETCDF=1 ^
      -D ENABLE_PNG=1 ^
      -D ENABLE_PYTHON=0 ^
      -D ENABLE_FORTRAN=0 ^
      -D DISABLE_OS_CHECK=ON ^
      %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

ctest
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
