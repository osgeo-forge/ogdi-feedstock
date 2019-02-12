:: Build using msys2's make

:: Some workflow culled from conda-forge::gettext Win recipe approach
::   (though that compiles directly with VS)
:: Delegate to the packaging script. We need to translate the key path variables
:: to be Unix-y rather than Windows-y, though.

set "MSYS2_ARG_CONV_EXCL=/AI;/AL;/OUT;/out"

set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1

set "saved_recipe_dir=%RECIPE_DIR%"
:: NOTE: cygpath.exe -u will prefix with /cygdrive *outside* of msys2
FOR /F "delims=" %%i IN ('cygpath.exe -u -p "%PATH%"') DO set "PATH_OVERRIDE=%%i"
:: LIBRARY_PREFIX_M=Q:/osgf/conda-bld/_h_env/Library
FOR /F "delims=" %%i IN ('cygpath.exe -m "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX_M=%%i"
:: LIBRARY_PREFIX_U=/q/osgf/conda-bld/_h_env/Library
FOR /F "delims=" %%i IN ('cygpath.exe -u "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX_U=%%i"
:: RECIPE_DIR=/c/conda/osgeo-forge/feedstocks/pkg/recipe
FOR /F "delims=" %%i IN ('cygpath.exe -u "%RECIPE_DIR%"') DO set "RECIPE_DIR=%%i"
:: SRC_DIR=/q/osgf/conda-bld/work
FOR /F "delims=" %%i IN ('cygpath.exe -a -m "%SRC_DIR%"') DO set "SRC_DIR=%%i"
:: SRC_DIR_M=Q:/osgf/conda-bld/work
FOR /F "delims=" %%i IN ('cygpath.exe -m "%SRC_DIR%"') DO set "SRC_DIR_M=%%i"

copy /y %saved_recipe_dir%\common.mak config\

make TOPDIR=%SRC_DIR% TARGET=win64 OVERRIDE_COMMON_MAK=yes clean
if errorlevel 1 exit 1

set opts=TOPDIR=%SRC_DIR% TARGET=win64 OVERRIDE_COMMON_MAK=yes ^
  FG=release TARGET=win64 ^
  CPP_RELEASE="-I%SRC_DIR_M%/include/win32 -D_AMD64_=1 -D_CRT_SECURE_NO_WARNINGS=1 -D_WINREG_=1 -DDUMMY_NAD_CVT" ^
  PROJ_SETTING=external ^
  PROJ_INCLUDE="-I%LIBRARY_PREFIX_M%/include" ^
  PROJ_STATICLIB="%LIBRARY_PREFIX_M%/lib/proj_i.lib" ^
  ZLIB_SETTING=external ^
  ZLIB_INCLUDE="-I%LIBRARY_PREFIX_M%/include" ^
  ZLIB_LINKLIB="%LIBRARY_PREFIX_M%/lib/zdll.lib" ^
  EXPAT_SETTING=external ^
  EXPAT_INCLUDE="-I%LIBRARY_PREFIX_M%/include" ^
  EXPAT_LINKLIB="%LIBRARY_PREFIX_M%/lib/expat.lib"

make %opts%
if errorlevel 1 exit 1

make %opts% install
if errorlevel 1 exit 1

pushd install

  :: Skip example exes
  for %%G in (gltpd ogdi_import ogdi_info rpcgen) do (
    copy /y bin\%%G.exe "%LIBRARY_BIN%\"
  )

  copy /y "lib\\*.dll" "%LIBRARY_BIN%\"

  mkdir "%LIBRARY_INC%\ogdi"
  xcopy /s /y /i include\ogdi "%LIBRARY_INC%\ogdi"

popd

pushd lib

  :: Skip static libs
  for %%G in (adrg dtcanada dted dtusa ogdi remote rpf skeleton vrf) do (
    copy /y win64\%%G.lib "%LIBRARY_LIB%\"
  )

popd
