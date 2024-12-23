## December 22, 2024

- Added a PowerShell command to modify _png_pvt.h_ to work with my build of PNG. OpenImageIO is starting to add support for automatically building dependencies. They changed the path of _png.h_ in _png_pvt.h_, but my PNG includes aren't in that location. This change should still work fine with older versions of the OIIO source.

## August 20, 2024

- First release.
