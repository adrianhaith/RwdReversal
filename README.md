## To Install:

This is only guaranteed on Ubuntu 14.04 LTS with Octave 4.0.1, but
MATLAB on any system should be fine.

### Install On Ubuntu With Octave/PTB-3

To get the most recent version of Octave (4.0.1), use (adapted from [here](http://askubuntu.com/questions/645600/how-to-install-octave-4-0-0-in-ubuntu-14-04)):

```
sudo apt-get install libportaudio-ocaml-dev
sudo apt-get build-dep octave
wget ftp://ftp.gnu.org/gnu/octave/octave-4.0.1.tar.gz
tar xf octave-4.0.1.tar.gz
cd octave-4.0.1/
./configure
make
sudo make install
```
4.0.1 seemed necessary because 4.0.0 gave me issues with `classdef` and
the like, and works well enough on cursory inspection.

Then, before installing Psychtoolbox, make sure the following prerequisites are installed:

```
sudo apt-get install subversion freeglut3 freeglut3-dev rhythmbox libusb-1.0 libdc1394-22-dev
```

Then download [DownloadPsychtoolbox.m](https://raw.githubusercontent.com/Psychtoolbox-3/Psychtoolbox-3/master/Psychtoolbox/DownloadPsychtoolbox.m).
Run
```
DownloadPsychtoolbox('/home/foo/toolbox')
```

These steps take a fair amount of time, so plan ahead!

## Install for MATLAB (Windows)

Make sure that you have ASIO and libusb in the right places. To install ASIO,
download ASIO4All from http://asio4all.com/, and then move the portaudio dll from
`C:\toolbox\Psychtoolbox\PsychSound\portaudio_x64.dll` to `C:\Windows\system32\`.

libusb-1.0.dll is located in `C:\toolbox\Psychtoolbox\PsychContributed\`. Move it
to system32 as well.
