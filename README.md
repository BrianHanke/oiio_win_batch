# oiio_win_batch
 
Batch script to easily build OpenImageIO on Windows.

The project path is hardcoded to `C:\Source\oiio` for now. It's easy enough to change it via find and replace if desired.

# Build Guide

1. Make sure you have Visual Studio and CMake installed. I use VS Community 2022 and CMake 3.27.1.
2. Clean up your Windows Path to remove any possible conflicts such as existing OpenImageIO installs, OpenRV, Strawberry Perl, etc. You basically just want Visual Studio and CMake and that's it.
3. Launch a Developer Command Prompt for VS 2022.
4. Navigate to where you downloaded `oiio.bat` and run it.
5. After everything is built VS will launch `OpenImageIO.sln`. You can build whatever part of the project you want. Make sure to set the configuration to `Release`.
   
   ![oiio](https://github.com/BrianHanke/oiio_win_batch/assets/59420805/8840f297-a327-4835-bc2f-b7848278d63c)
   
7. Final binaries and required DLLs will be in `C:\Source\oiio\oiio\build\bin\Release`.
8. Enjoy!
