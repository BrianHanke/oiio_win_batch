# oiio_win_batch
 
Batch script to easily build OpenImageIO on Windows.

The projct path is hardcoded to c:\source\oiio for now. It's easy enough to change it via find and replace if you want. (Note that if you do change the paths it will mess up the libpng step since that has a reference to C:\Source\oiio\zlib in the source.)

# Build Guide

1. Make sure you have Visual Studio and CMake intalled. I use VS Community 2022 and CMake 3.27.1.
2. Clean up your Windows PATH to remove any possible conflicts such as existing OpenImageIO installs, OpenRV, Strawberry Perl, etc. You basically just want Visual Studio and CMake and that's it.
3. Launch a Developer Command Prompt for VS 2022.
4. Navaigate to where you downloaded oiio.bat and run it.
5. After everything is built VS will launch the OpenImageIO.sln project. You can build whatever part you want. Make sure to set the configuration to Release.
6. Final binaries will be in c:\source\oiio\oiio\build\bin\Release.
7. Enjoy!
