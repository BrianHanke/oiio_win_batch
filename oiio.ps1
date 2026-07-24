##################################################################################################
# User-defined variables

$projRoot = "C:/Source/oiio"

$loadSolution = $false # Load OpenImageIO.sln in Visual Studio
$buildOiiotool = $true # Build and test oiiotool
$pauseAfterStep = $true # Wait for key press after each build step

##################################################################################################

$ErrorActionPreference = "Stop"

$zlibRoot = "$projRoot/zlib"
$tiffRoot = "$projRoot/libtiff"
$exrRoot = "$projRoot/openexr"
$jpegRoot = "$projRoot/libjpeg-turbo"
$pngRoot = "$projRoot/libpng"
$ocioRoot = "$projRoot/ocio"
$fmtRoot = "$projRoot/fmt"
$robinmapRoot = "$projRoot/robin-map"
$oiioRoot = "$projRoot/oiio"
$freetypeRoot = "$projRoot/freetype"
$webpRoot = "$projRoot/webp"
$openjpegRoot = "$projRoot/openjpg"
$rawRoot = "$projRoot/LibRaw-0.22.2"
$ffmpegRoot = "$projRoot/ffmpeg-master-latest-win64-gpl-shared"

# Initialize timer
$sw = [System.Diagnostics.Stopwatch]::StartNew()

$Path = @(
	"$env:SystemRoot\system32",
	"$env:SystemRoot",
	"$env:SystemRoot\System32\Wbem",
	"$env:SystemRoot\System32\WindowsPowerShell\v1.0\",
	"C:\Program Files\Git\cmd",
	"C:\Program Files\CMake\bin",
	"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\"
)
$env:PATH = $Path -join ';'

function Import-VsEnvironment {
	param(
		[string]$Arch = "x64",
		[string]$VsVersion = "2022",
		[string]$Edition = "Community"
	)

	Write-Host "Setting up Visual Studio environment..." -ForegroundColor Cyan

	$vcvars = "C:\Program Files\Microsoft Visual Studio\$VsVersion\$Edition\VC\Auxiliary\Build\vcvarsall.bat"

	if (-not (Test-Path $vcvars)) {
		throw "Could not find vcvarsall.bat at $vcvars"
	}

	$cmd = "`"$vcvars`" $Arch && set"
	$envVars = cmd.exe /c $cmd

	foreach ($var in $envVars) {
		if ($var -match "^(?<Name>[^=]+)=(?<Value>.*)$") {
			Set-Item -Path "env:$($Matches['Name'])" -Value $Matches['Value']
		}
	}

	Write-Host "Done." -ForegroundColor Cyan
}

Import-VsEnvironment

New-Item -Path $projRoot -ItemType Directory -Force | Out-Null
Set-Location $projRoot

function Build-Task {
	param(
		[string]$Message,
		[scriptblock]$Action

		)
	Write-Host "`n$Message...`n" -ForegroundColor Cyan
	& $Action

	if ($pauseAfterStep) {
		Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
		$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
}

##################################################################################################
# Configure dependencies
##################################################################################################

# zlib
Build-Task "Building zlib" {
	Set-Location $projRoot
	if (-not (Test-Path $zlibRoot)) {
		git clone --branch v1.3.1 https://github.com/madler/zlib $zlibRoot
	}
	Set-Location $zlibRoot
	cmake -S . -B build -DCMAKE_INSTALL_PREFIX=dist `
		-DZLIB_BUILD_EXAMPLES=OFF `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
	cmake --build build --config Release --target install
}

# OpenEXR
Build-Task "Building OpenEXR" {
	Set-Location $projRoot
	if (-not (Test-Path $exrRoot)) {
		git clone --branch v3.3.5 https://github.com/AcademySoftwareFoundation/openexr $exrRoot
	}
	Set-Location $exrRoot
	cmake -S . -B build -DCMAKE_BUILD_TYPE=Release `
		-DCMAKE_INSTALL_PREFIX=dist `
		-DOPENEXR_FORCE_INTERNAL_DEFLATE=ON `
		-DBUILD_TESTING=OFF `
		-DBUILD_WEBSITE=OFF `
		-DOPENEXR_BUILD_EXAMPLES=OFF `
		-DOPENEXR_BUILD_TOOLS=OFF `
		-DOPENEXR_BUILD_PYTHON=OFF `
		-DOPENEXR_INSTALL_TOOLS=OFF `
		-DOPENEXR_INSTALL_DOCS=OFF `
		-DOPENEXR_INSTALL_PKG_CONFIG=OFF `
		-DOPENEXR_LIB_SUFFIX="" `
		-DIMATH_LIB_SUFFIX="" `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
	cmake --build build --config Release --target install
}

# fmt
Build-Task "Building fmt" {
	Set-Location $projRoot
	if (-not (Test-Path $fmtRoot)) {
		git clone --branch 12.1.0 https://github.com/fmtlib/fmt.git $fmtRoot
	}
	Set-Location $fmtRoot
	cmake -S . -B build -DCMAKE_BUILD_TYPE=Release `
		-DCMAKE_INSTALL_PREFIX=dist `
		-DFMT_TEST=OFF `
		-DFMT_DOC=OFF `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
	cmake --build build --config Release --target install
}

# robin-map
Build-Task "Building robin-map" {
	Set-Location $projRoot
	if (-not (Test-Path $robinmapRoot)) {
		git clone --branch v1.4.0 https://github.com/Tessil/robin-map.git $robinmapRoot
	}
	Set-Location $robinmapRoot
	cmake -S . -B build -DCMAKE_INSTALL_PREFIX=dist `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
	cmake --build build --config Release --target install
}

# libjpeg-turbo
Build-Task "Building libjpeg-turbo" {
	Set-Location $projRoot
	if (-not (Test-Path $jpegRoot)) {
		git clone --branch 3.1.2 https://github.com/libjpeg-turbo/libjpeg-turbo $jpegRoot
	}
	Set-Location $jpegRoot
	cmake -S . -B build -DCMAKE_BUILD_TYPE=Release `
		-DENABLE_SHARED=FALSE `
		-DCMAKE_INSTALL_PREFIX=dist `
		-DWITH_TOOLS=FALSE `
		-DWITH_TESTS=FALSE `
		-DWITH_JPEG8=0 `
        -DCMAKE_INSTALL_LIBDIR=lib `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
	cmake --build build --config Release --target install
}

# LibTIFF
Build-Task "Building LibTIFF" {
	Set-Location $projRoot
	if (-not (Test-Path $tiffRoot)) {
		git clone --branch v4.7.1 https://gitlab.com/libtiff/libtiff.git $tiffRoot
	}
	Set-Location $tiffRoot
	cmake -S . -B build -DCMAKE_BUILD_TYPE=Release `
		-DBUILD_SHARED_LIBS=OFF `
		-DCMAKE_INSTALL_PREFIX=dist `
        -DCMAKE_INSTALL_LIBDIR=lib `
        -Dtiff-tools=OFF `
        -Dtiff-contrib=OFF `
        -Dtiff-tests=OFF `
        -Dtiff-docs=OFF `
        -Dlibdeflate=OFF `
        -Dlzma=OFF `
        -Dzstd=OFF `
        -Djbig=OFF `
        -Dlerc=OFF `
		-DZLIB_ROOT="$zlibRoot/dist" `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
	cmake --build build --config Release --target install
}

# libpng
Build-Task "Building libpng" {
	Set-Location $projRoot
    if (-not (Test-Path $pngRoot)) {
        git clone --branch v1.6.5 https://github.com/pnggroup/libpng.git $pngRoot
    }
    Set-Location $pngRoot
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release `
		-DCMAKE_POLICY_DEFAULT_CMP0074=NEW `
		-DCMAKE_POLICY_VERSION_MINIMUM="3.5" `
		-DPNG_SHARED=OFF `
		-DPNG_STATIC=ON `
        -DPNG_TESTS=OFF `
        -DCMAKE_INSTALL_LIBDIR=lib `
		-DCMAKE_INSTALL_PREFIX=dist `
		-DZLIB_ROOT="$zlibRoot/dist" `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
    cmake --build build --config Release --target install
}

# OpenColorIO
Build-Task "Building OpenColorIO" {
	Set-Location $projRoot
	if (-not (Test-Path $ocioRoot)) {
		git clone --branch v2.5.1 https://github.com/AcademySoftwareFoundation/OpenColorIO.git $ocioRoot
	}
	Set-Location $ocioRoot
	cmake -S . -B build -DCMAKE_BUILD_TYPE=Release `
        -DOCIO_BUILD_APPS=OFF `
        -DOCIO_BUILD_GPU_TESTS=OFF `
        -DOCIO_BUILD_PYTHON=OFF `
        -DOCIO_BUILD_TESTS=OFF `
        -DOCIO_USE_OIIO_FOR_APPS=OFF `
		-DOCIO_INSTALL_EXT_PACKAGES=MISSING `
		-DZLIB_ROOT="$zlibRoot/dist" `
		-DIMATH_ROOT="$exrRoot/dist/lib/cmake/Imath" `
		-DCMAKE_INSTALL_PREFIX=dist `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
	cmake --build build --config Release --target install
}

# FreeType
Build-Task "Building FreeType" {
    Set-Location $projRoot
    if (-not (Test-Path $freetypeRoot)) {
        git clone --branch VER-2-14-1 https://github.com/freetype/freetype.git $freetypeRoot
    }
    Set-Location $freetypeRoot
    cmake -S . -B build `
        -DBUILD_SHARED_LIBS=OFF `
        -DFT_DISABLE_ZLIB=ON `
        -DFT_DISABLE_PNG=ON `
        -DFT_DISABLE_HARFBUZZ=ON `
        -DFT_DISABLE_BZIP2=ON `
		-DFT_DISABLE_BROTLI=ON `
        -DCMAKE_INSTALL_PREFIX=dist `
        -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
    cmake --build build --config Release --target install
}

# WebP
Build-Task "Building WebP" {
    Set-Location $projRoot
    if (-not (Test-Path $webpRoot)) {
        git clone --branch v1.6.0 https://github.com/webmproject/libwebp.git $webpRoot
    }
    Set-Location $webpRoot
    cmake -S . -B build `
        -DBUILD_SHARED_LIBS=OFF `
        -DWEBP_BUILD_CWEBP=OFF `
        -DWEBP_BUILD_DWEBP=OFF `
        -DWEBP_BUILD_GIF2WEBP=OFF `
        -DWEBP_BUILD_IMG2WEBP=OFF `
        -DWEBP_BUILD_VWEBP=OFF `
        -DWEBP_BUILD_WEBPINFO=OFF `
        -DWEBP_BUILD_WEBPMUX=ON `
        -DWEBP_BUILD_EXTRAS=OFF `
        -DCMAKE_INSTALL_PREFIX=dist `
        -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
    cmake --build build --config Release --target install
}

# OpenJPEG
Build-Task "Building OpenJPEG" {
    Set-Location $projRoot
    if (-not (Test-Path $openjpegRoot)) {
        git clone --branch v2.5.4 https://github.com/uclouvain/openjpeg.git $openjpegRoot
    }
    Set-Location $openjpegRoot
    cmake -S . -B build `
        -DCMAKE_BUILD_TYPE=Release `
        -DBUILD_DOC=OFF `
		-DBUILD_SHARED_LIBS=OFF `
		-DBUILD_CODEC=OFF `
        -DCMAKE_INSTALL_PREFIX=dist `
        -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF
    cmake --build build --config Release --target install
}

# LibRaw
Build-Task "Setting Up LibRaw" {
	$LibrawZip = Join-Path $env:TEMP "LibRaw-0.22.2-Win64.zip"
	$LibrawUrl = "https://www.libraw.org/data/LibRaw-0.22.2-Win64.zip"

	Write-Host "Downloading LibRaw 0.22.2..."
	Invoke-WebRequest -Uri $LibrawUrl -OutFile $LibrawZip

	Write-Host "Extracting..."
	Expand-Archive -Path $LibrawZip -DestinationPath $projRoot -Force

	Write-Host "Cleaning up..."
	Remove-Item -Path $LibrawZip -Force

	Write-Host "LibRaw setup complete." -ForegroundColor Green
}

# FFmpeg
Build-Task "Setting Up FFpeg" {
	$FfmpegZip = Join-Path $env:TEMP "ffmpeg-master-latest-win64-gpl-shared.zip"
	$FfmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip"

	Write-Host "Downloading FFpeg..."
	Invoke-WebRequest -Uri $FfmpegUrl -OutFile $FfmpegZip

	Write-Host "Extracting..."
	Expand-Archive -Path $FfmpegZip -DestinationPath $projRoot -Force

	Write-Host "Cleaning up..."
	Remove-Item -Path $FfmpegZip -Force

	Write-Host "FFmpeg setup complete." -ForegroundColor Green
}

#################################################################################################
# Dependencies to-do
#################################################################################################

# GIF 5.2.1 - NO
# Libheif - MAYBE
# libuhdr - MAYBE
# openjph 0.3.1 - MAYBE
# Ptex - NO
# DCMTK - NO
# JXL - MAYBE

##################################################################################################
# OpenImageIO
##################################################################################################

Build-Task "Configuring OpenImageIO" {
	Set-Location $projRoot
	if (-not (Test-Path "$oiioRoot")) {
		git clone --branch release https://github.com/AcademySoftwareFoundation/OpenImageIO.git $oiioRoot
	}
	Set-Location $oiioRoot
	cmake -S . -B build -DVERBOSE=ON `
		-DCMAKE_BUILD_TYPE=Release `
		-DZLIB_ROOT="$zlibRoot/dist" `
		-DFMT_ROOT="$fmtRoot/dist" `
		-DROBINMAP_ROOT="$robinmapRoot/dist" `
		-DTIFF_ROOT="$tiffRoot/dist" `
		-DOpenEXR_ROOT="$exrRoot/dist" `
		-DImath_DIR="$exrRoot/dist/lib/cmake/Imath" `
		-Dlibjpeg-turbo_ROOT="$jpegRoot/dist" `
		-DJPEG_ROOT="$jpegRoot/dist" `
		-DFREETYPE_ROOT="$freetypeRoot/dist" `
		-DPNG_ROOT="$pngRoot/dist" `
		-DOpenColorIO_ROOT="$ocioRoot/dist" `
		-DWebP_ROOT="$webpRoot/dist" `
		-DOpenJPEG_ROOT="$openjpegRoot/dist" `
		-DLibRaw_ROOT="$rawRoot" `
		-DFFmpeg_ROOT="$ffmpegRoot" `
		-DUSE_PYTHON=0 `
		-DUSE_QT=0 `
		-DOIIO_BUILD_TESTS=0 `
		-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF

	$BinRelease = "$oiioRoot/build/bin/Release"
	New-Item -Path $BinRelease -ItemType Directory -Force | Out-Null

	Copy-Item "$ocioRoot\dist\bin\*.dll" -Destination $BinRelease -Force
	Copy-Item "$exrRoot\dist\bin\*.dll" -Destination $BinRelease -Force
	Copy-Item "$rawRoot\bin\*.dll" -Destination $BinRelease -Force
	Copy-Item "$zlibRoot\dist\bin\*.dll" -Destination $BinRelease -Force
	Copy-Item "$ffmpegRoot\bin\*.dll" -Destination $BinRelease -Force
}

$sw.Stop()
$elapsed = $sw.Elapsed
Write-Host ("`nTotal configuration time: {0}m {1}s" -f [math]::Truncate($elapsed.TotalMinutes), $elapsed.Seconds) -ForegroundColor Green

if ($loadSolution) {
	devenv "$oiioRoot/build/OpenImageIO.sln"
}

if ($buildOiiotool) {
	Set-Location $oiioRoot
	cmake --build build --config Release --target oiiotool

	# Test oiiotool
	Set-Location $oiioRoot/build/bin/Release
	./oiiotool --help
}