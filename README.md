A set of scripts which supports building
various projects for Windows on the Jenkins system.

The system is currently hosted at
https://ku.myftp.org/buildbot/

The mostly notable projects it builds are:
* mpv - http://mpv.io/
* mplayer2 - http://www.mplayer2.org/

These projects are built with MinGW-w64 toolchains,
and the build process is not so trivial since they
require autotools and many dependences to build properly
and enable useful features.
