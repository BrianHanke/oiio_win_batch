# OiioBuildHelper

PowerShell script to easily build OpenImageIO on Windows. Automatically sets up all major dependencies, including OpenEXR, OpenColorIO, libpng, libjpeg-turbo, LibRaw, FFmpeg, and more.

There are still a few optional features missing:

- GIF: hard to build on Windows and a very outdated image format anyway.
- Ptex, libuhdr, openjph, libheif and JXL: infrequently used.
- DCMTK: a niche library for medical imaging.

# Build Guide

1. Make sure you have Visual Studio (any edition, Desktop C++ Workload), Git and CMake installed. That's all you need!
2. Open _oiio.ps1_ in a text editor and modify the first set of variables to suit your needs. Descriptions of what everything does are included in the code comments.
3. Launch PowerShell, navigate to where you downloaded this repo, and type `./oiio.ps1`.
4. The build takes 10 minutes or less. Depending on which options you chose in the script the OpenImageIO Visual Studio solution might launch for you to work on, or _oiiotool_ will be built and given a test run.
5. Any final binaries you build, plus all required DLLs, can be found in _$projRoot\oiio\build\bin\Release_.
