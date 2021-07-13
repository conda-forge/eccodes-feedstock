mkdir build && cd build

set CFLAGS=
set CXXFLAGS=

cmake -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D OPENJPEG_INCLUDE_DIR=%LIBRARY_INC%\openjpeg-2.4 ^
      -D OPENJPEG_PATH=%LIBRARY_PREFIX% ^
      -D ENABLE_FORTRAN=0 ^
      -D ENABLE_PYTHON=0 ^
      -D ENABLE_NETCDF=1 ^
      -D ENABLE_JPG=1 ^
      -D ENABLE_PNG=1 ^
      -D IEEE_LE=1 ^
      -D ENABLE_MEMFS=1 ^
      -D ENABLE_EXTRA_TESTS=OFF ^
      %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

:: so tests can find eccodes.dll
set PATH=%PATH%;%LIBRARY_BIN%;%SRC_DIR%\build\bin

ctest --output-on-failure
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

:: install activate/deactive scripts
set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\eccodes-activate.bat
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\eccodes-deactivate.bat
if errorlevel 1 exit 1
