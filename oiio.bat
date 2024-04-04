@rem Custom Path - delete or replace

@set PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.38.33130\bin\HostX86\x86;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\VC\VCPackages;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer;C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\bin\Roslyn;C:\Program Files\Microsoft Visual Studio\2022\Community\Team Tools\Performance Tools;C:\Program Files (x86)\Microsoft Visual Studio\Shared\Common\VSPerfCollectionTools\vs2019\;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\FSharp\Tools;C:\Program Files\Microsoft Visual Studio\2022\Community\Team Tools\DiagnosticsHub\Collector;C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\\x86;C:\Program Files (x86)\Windows Kits\10\bin\\x86;C:\Program Files\Microsoft Visual Studio\2022\Community\\MSBuild\Current\Bin\amd64;C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\;C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\amd64;C:\Program Files (x86)\Common Files\Intel\Shared Libraries\redist\intel64_win\compiler;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Windows\system32;C:\Windows;C:\Program Files\dotnet\;C:\Program Files\Git\cmd;C:\languages\rust\.cargo\bin;C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.38.33130\bin\HostX86\x86;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\VC\VCPackages;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer;C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\bin\Roslyn;C:\Program Files\Microsoft Visual Studio\2022\Community\Team Tools\Performance Tools;C:\Program Files (x86)\Microsoft Visual Studio\Shared\Common\VSPerfCollectionTools\vs2019\;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\FSharp\Tools;C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\\x86;C:\Program Files (x86)\Windows Kits\10\bin\\x86;C:\Users\Brian\AppData\Local\Programs\Microsoft VS Code\bin;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\VC\Linux\bin\ConnectionManagerExe;C:\Program Files\Microsoft Visual Studio\2022\Community\VC\vcpkg

@rem End custom Path

@set PROJ_ROOT=c:\source\oiio

@set BOOST_ROOT=%PROJ_ROOT%\boost
@set ZLIB_ROOT=%PROJ_ROOT%\zlib
@set TIFF_ROOT=%PROJ_ROOT%\libtiff
@set EXR_ROOT=%PROJ_ROOT%\openexr
@set JPEG_ROOT=%PROJ_ROOT%\libjpeg-turbo
@set PNG_ROOT=%PROJ_ROOT%\libpng
@set OCIO_ROOT=%PROJ_ROOT%\OpenColorIO\release

@set start_time=%date% %time%

mkdir %PROJ_ROOT%
cd %PROJ_ROOT%

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
copy %ZLIB_ROOT%\include\zconf.h %ZLIB_ROOT%
cd ..

call git clone https://github.com/AcademySoftwareFoundation/openexr
cd openexr
call cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=dist -DBUILD_TESTING=OFF -DOPENEXR_BUILD_TOOLS=OFF -DOPENEXR_INSTALL_TOOLS=OFF -DOPENEXR_INSTALL_EXAMPLES=OFF -DZLIB_ROOT=%ZLIB_ROOT%
call cmake --build build --target install --config Release
cd ..

call git clone https://github.com/AcademySoftwareFoundation/OpenColorIO.git
cd OpenColorIO
call cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_APPS=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_PYTHON=OFF -DOCIO_BUILD_DOCS=OFF -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_PYGLUE=OFF -DOCIO_BUILD_GPU_TESTS=OFF -DOCIO_BUILD_JAVA=OFF -DZLIB_ROOT=%ZLIB_ROOT%
call cmake --build build --config Release --target install
mkdir %OCIO_ROOT%
xcopy /s "C:\Program Files (x86)\OpenColorIO" %OCIO_ROOT%
rmdir /s /q "C:\Program Files (x86)\OpenColorIO"
cd ..

call git clone https://gitlab.com/libtiff/libtiff.git
cd libtiff
call git checkout v4.3.0 --force
call cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -Dlibdeflate=ON -DBUILD_SHARED_LIBS=ON -DZLIB_ROOT=%ZLIB_ROOT% -DCMAKE_INSTALL_PREFIX=%TIFF_ROOT%\dist
call cmake --build build --target install
cd ..

call git clone https://github.com/libjpeg-turbo/libjpeg-turbo
cd libjpeg-turbo
call cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED=OFF -DCMAKE_INSTALL_PREFIX="."
call cmake --build build --config Release --target install
cd ..

call git clone https://github.com/BrianHanke/libpng.git
cd %PNG_ROOT%\projects\vstudio
call devenv vstudio.sln /Build "Release|x64"

mkdir %PNG_ROOT%\dist
mkdir %PNG_ROOT%\dist\bin
mkdir %PNG_ROOT%\dist\lib
mkdir %PNG_ROOT%\dist\include

copy %PNG_ROOT%\projects\vstudio\x64\Release\*.exe %PNG_ROOT%\dist\bin\
copy %PNG_ROOT%\projects\vstudio\x64\Release\libpng16.dll %PNG_ROOT%\dist\bin\
copy %PNG_ROOT%\projects\vstudio\x64\Release\libpng16.lib %PNG_ROOT%\dist\lib\
copy %PNG_ROOT%\png.h %PNG_ROOT%\dist\include\
copy %PNG_ROOT%\pngconf.h %PNG_ROOT%\dist\include\
copy %PNG_ROOT%\pnglibconf.h %PNG_ROOT%\dist\include\

cd %PROJ_ROOT%

mkdir oiio
cd oiio
call git clone https://github.com/AcademySoftwareFoundation/OpenImageIO.git .
call git checkout origin/release
mkdir build
cd build
call cmake -DVERBOSE=ON -DCMAKE_BUILD_TYPE=Release -DBoost_USE_STATIC_LIBS=ON -DBoost_NO_WARN_NEW_VERSIONS=ON -DBoost_ROOT=%BOOST_ROOT% -DZLIB_ROOT=%ZLIB_ROOT% -DTIFF_ROOT=%TIFF_ROOT%\dist -DOpenEXR_ROOT=%EXR_ROOT%\dist -DImath_DIR=%EXR_ROOT%\dist\lib\cmake\Imath -DJPEG_ROOT=%JPEG_ROOT% -DPNG_ROOT=%PNG_ROOT%\dist -DOpenColorIO_ROOT=%OCIO_ROOT% -DUSE_PYTHON=0 -DUSE_QT=0 -DOIIO_BUILD_TESTS=0 ..

mkdir %PROJ_ROOT%\oiio\build\bin\Release
copy %PNG_ROOT%\dist\bin\libpng16.dll %PROJ_ROOT%\oiio\build\bin\Release\
copy %PROJ_ROOT%\zlib\build\Release\zlib.dll %PROJ_ROOT%\oiio\build\bin\Release\
copy %PROJ_ROOT%\OpenColorIO\release\bin\*.dll %PROJ_ROOT%\oiio\build\bin\Release\
copy %PROJ_ROOT%\openexr\dist\bin\*.dll %PROJ_ROOT%\oiio\build\bin\Release\
copy %PROJ_ROOT%\libtiff\dist\bin\*.dll %PROJ_ROOT%\oiio\build\bin\Release\

@set end_time=%date% %time%

@powershell -command "&{$elapsed = ([datetime]::parse('%end_time%') - [datetime]::parse('%start_time%')); $minutes_raw = $elapsed.TotalSeconds / 60; $minutes = [Math]::Truncate($minutes_raw); $seconds = [Math]::Round($elapsed.TotalSeconds - ([Math]::Truncate($minutes_raw) * 60)); echo (-join('Total build time: ', $minutes, 'm ', $seconds, 's')); }"

call devenv OpenImageIO.sln