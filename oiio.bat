@set BOOST_ROOT=c:\source\oiio\boost
@set ZLIB_ROOT=c:\source\oiio\zlib
@set TIFF_ROOT=c:\source\oiio\libtiff
@set EXR_ROOT=c:\source\oiio\openexr
@set JPEG_ROOT=c:\source\oiio\libjpeg-turbo
@set PNG_ROOT=c:\source\oiio\libpng\projects\vstudio\Release

@set start_time=%date% %time%

mkdir c:\source\oiio
cd c:\source\oiio

call git clone --recursive https://github.com/boostorg/boost.git
cd boost
call bootstrap
call b2
cd ..

call git clone https://github.com/madler/zlib
cd zlib
call cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=.
call cmake --build build --config Release --target install
del build\Release\zlib.lib
copy c:\source\oiio\zlib\include\zconf.h c:\source\oiio\zlib\
cd ..

call git clone https://gitlab.com/libtiff/libtiff.git
cd libtiff
call cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=.
call cmake --build build --target install
cd ..

call git clone https://github.com/libjpeg-turbo/libjpeg-turbo
cd libjpeg-turbo
call cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED=OFF -DCMAKE_INSTALL_PREFIX="."
call cmake --build build --config Release --target install
cd ..

call git clone https://github.com/AcademySoftwareFoundation/openexr
cd openexr
call cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=dist -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=OFF -DOPENEXR_BUILD_TOOLS=OFF -DOPENEXR_INSTALL_TOOLS=OFF -DOPENEXR_INSTALL_EXAMPLES=OFF -DZLIB_ROOT=%ZLIB_ROOT%
call cmake --build build --target install --config Release
cd ..

call git clone https://github.com/BrianHanke/libpng.git
cd c:\source\oiio\libpng\projects\vstudio
call devenv vstudio.sln /Build "Release|x64"

mkdir c:\source\oiio\libpng\projects\vstudio\Release
mkdir c:\source\oiio\libpng\projects\vstudio\Release\bin
mkdir c:\source\oiio\libpng\projects\vstudio\Release\lib
mkdir c:\source\oiio\libpng\projects\vstudio\Release\include

copy c:\source\oiio\libpng\projects\vstudio\x64\Release\*.exe c:\source\oiio\libpng\projects\vstudio\Release\bin\
copy c:\source\oiio\libpng\projects\vstudio\x64\Release\libpng16.dll c:\source\oiio\libpng\projects\vstudio\Release\bin\
copy c:\source\oiio\libpng\projects\vstudio\x64\Release\libpng16.lib c:\source\oiio\libpng\projects\vstudio\Release\lib\
copy c:\source\oiio\libpng\png.h c:\source\oiio\libpng\projects\vstudio\Release\include\
copy c:\source\oiio\libpng\pngconf.h c:\source\oiio\libpng\projects\vstudio\Release\include\
copy c:\source\oiio\libpng\pnglibconf.h c:\source\oiio\libpng\projects\vstudio\Release\include\

cd c:\source\oiio

call git clone https://github.com/OpenImageIO/oiio.git
cd oiio
mkdir build
cd build
call cmake -DVERBOSE=ON -DCMAKE_BUILD_TYPE=Release -DBoost_USE_STATIC_LIBS=ON -DBoost_NO_WARN_NEW_VERSIONS=ON -DBoost_ROOT=%BOOST_ROOT% -DZLIB_ROOT=%ZLIB_ROOT% -DTIFF_ROOT=%TIFF_ROOT% -DOpenEXR_ROOT=%EXR_ROOT%\dist -DImath_DIR=%EXR_ROOT%\dist\lib\cmake\Imath -DJPEG_ROOT=%JPEG_ROOT% -DPNG_ROOT=%PNG_ROOT% -DUSE_PYTHON=0 -DUSE_QT=0 -DBUILD_SHARED_LIBS=0 -DLINKSTATIC=1 -DOIIO_BUILD_TESTS=0 ..

mkdir c:\source\oiio\oiio\build\bin\Release
copy c:\source\oiio\libpng\projects\vstudio\Release\bin\libpng16.dll c:\source\oiio\oiio\build\bin\Release\
copy c:\source\oiio\zlib\build\Release\zlib.dll c:\source\oiio\oiio\build\bin\Release\

@set end_time=%date% %time%

@powershell -command "&{$elapsed = ([datetime]::parse('%end_time%') - [datetime]::parse('%start_time%')); $minutes_raw = $elapsed.TotalSeconds / 60; $minutes = [Math]::Truncate($minutes_raw); $seconds = [Math]::Round($elapsed.TotalSeconds - ([Math]::Truncate($minutes_raw) * 60)); echo (-join('Total build time: ', $minutes, 'm ', $seconds, 's')); }"

call devenv OpenImageIO.sln