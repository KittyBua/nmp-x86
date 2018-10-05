# nmp-x86/x64
small build environment for nmp-tangos (or other flavours) for x86/x64

tested with Ubuntu Mate 16.04 x64

| flavour | repo | branch |
|---|---|---|
|**tangos**|**TangoCash/neutrino-mp-tangos**|**master**|
|classic|Duckbox-Developers/neutrino-mp-ddt|master|
|franken|fs-basis/neutrino-mp-fs|master|
|tuxbox|tuxbox-neutrino/gui-neutrino|master|
|vanilla|neutrino-mp/neutrino-mp|master|
|max|max_10/neutrino-mp-max|master|
|ni|neutrino-images/ni-neutrino-hd|ni/mp/tuxbox|

**add flavour with:**

`FLAVOUR=classic make update`
_or_
`FLAVOUR=classic make neutrino`

### prerequisites:

`sudo apt-get install`
- `build-essential autoconf libtool libtool-bin g++ gdb ccache libsigc++-2.0-dev`
- `libavformat-dev libswscale-dev libopenthreads-dev libbz2-dev`
- `libglew-dev freeglut3-dev libcurl4-gnutls-dev libfreetype6-dev libid3tag0-dev`
- `libmad0-dev libogg-dev libpng12-dev libgif-dev libjpeg62-dev libvorbis-dev`
- `libflac-dev libblkid-dev libao-dev libfribidi0 libfribidi-dev`
- `libgstreamer1.0-0 libgstreamer-plugins-base1.0-0`
- `libgstreamer-plugins-bad1.0-0 libgstreamer-plugins-good1.0-0`
- `libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev`
- `libgstreamer-plugins-bad1.0-dev libgstreamer-plugins-good1.0-dev`


