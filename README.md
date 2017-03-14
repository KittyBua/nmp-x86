# nmp-x86/x64
small build environment for nmp-tangos (or other flavours) for x86/x64

| flavour | repo | branch |
|---|---|---|
|**tangos**|**TangoCash/neutrino-mp-cst-next**|**master**|
|classic|Duckbox-Developers/neutrino-mp-cst-next|master|
|ni|Duckbox-Developers/neutrino-mp-cst-next|ni|
|franken|fs-basis/neutrino-mp-cst-next|test|
|skinned|TangoCash/neutrino-mp-cst-next|skinned|
|tuxbox|tuxbox-neutrino/gui-neutrino|pu/mp|
|vanilla|neutrino-mp/neutrino-mp|master|

**add flavour with:**

`FLAVOUR=classic make update`
_or_
`FLAVOUR=classic make neutrino`

### prerequisites:

`sudo apt-get install`
- `build-essential autoconf libtool libtool-bin g++ gdb ccache`
- `libavformat-dev libswscale-dev libopenthreads-dev`
- `libglew-dev freeglut3-dev libcurl4-gnutls-dev libfreetype6-dev libid3tag0-dev`
- `libmad0-dev libogg-dev libpng12-dev libgif-dev libjpeg62-dev libvorbis-dev`
- `libflac-dev libblkid-dev libao-dev libfribidi0 libfribidi-dev`
- `libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev`


