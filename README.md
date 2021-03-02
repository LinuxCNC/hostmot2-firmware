# hostmot2-firmware: build assorted hostmot2 FPGA firmwares automatically

# Note: This package is no longer maintained

In 2021, it became clear that the existing CI system that had built
hostmot2-firmware was no longer viable, and LinuxCNC project did not have the
developer time to rehabilitate it.  Because of this, and because we believe
that officially ending the maintanence of this project under the LinuxCNC
banner won't hamper users of LinuxCNC (including users of older cards such as
the 5i20, as it will remain possible to install old binary packages of
hostmot2-firmware), we have chosen to mark this package as unmaintained.

Mesa Electronics, the manufacturer of these FPGA cards, provide firmware in
source and binary format, under the GPL and other licenses, for their whole
range of LinuxCNC-compatible cards.

Back when Mesa's products typically did not include Flash chips to store
the FPGA configuration data, it was important to the LinuxCNC Project to
be able to offer these files as Debian packages and from their installation
media.  To that end, we created this system to build the firmware.

For recent Mesa cards that store their own firmware in non-volatile storage
(i.e., on an SPI Flash chip), there is no such requirement; a user can obtain
the firmware files from Mesa Electronics, load them once with mesaflash, and go
on their way.


## Overview

This package includes the hostmot2 source files along with Makefiles and
other scripts to automatically build all the desired variants of the
firmwares.

The PIN file format is intended to be human readable (not machine readable) so
it is not a requirement that it exactly match the format of existing PIN files.
There is also an experimental xml description format.

## ISE Version Requirements

Refer to `cards.py` for information about required ISE versions for particular
cards.  Currently, by installing ISE 13.4 and ISE 9.2, firmware can be built
for all supported cards.  With ISE 13.4, firmware can be built for all cards
except the venerable "5i20".

Xilinx still offers older versions of ISE free of charge.  At the time
of writing, the location is
http://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools/archive.html
and can also be reached from the xilinx.com front page by going to
"Support", "Downloads & Licensing", "ISE", "Archive".

## Building

Do not manually "source" or "." the settings.sh script into your shell before
invoking "make" or "dpkg-buildpackage".  The build process automatically finds
the right "settings.sh" script for each card if Xilinx ISE is installed into
the default location under /opt/Xilinx.

If you did not install in a location that the build process autodetects, create a set of symlinks to the required versions of ise, e.g.,:
~~~~
settings9.sh -> /opt/Xilinx19/settings32.sh
settings13.sh -> /opt/Xilinx13.4/settings32.sh
~~~~

To build all bitfiles, pinfiles, and xmlfiles:
    make -j4                   # -j setting depends on RAM and # CPU cores
Circa 2010, building the full set of firmwares took about 75 minutes wall time
with the -j4 setting on a system with 4 cores and 32GB RAM.

To build just a subset of firmwares, create a file `firmwares-local.txt` to list the firmware(s) you want to build.
This list is used instead of the list in `firmwares.txt`.
The first word in each line specifies the hostmot2 card, and the remaining words specify the pinfiles.
For example, to build just the 'SV12' firmware for the '5i23' card, put just this line in 'firmwares-local.txt':
    i23 SV12

To build Debian packages:
    debian/gencontrol
    export MAKEFLAGS=-j4 dpkg-buildpackage
                               # -j setting depends on RAM and # CPU cores

To build tar packages (must be in a git checkout):
    make -j4                   # -j setting depends on RAM and # CPU cores
    make dist
    # or make dist-force if your working tree is dirty



## Testing

A representative firmware for each supported board type has been tested:
 * 5i20, 5i22-1M, 5i23 (PCI)
 * 7i43-400 (EPP)
 * 3x20-1M (PCI-Express)
 * 4i65, 4i68 (PC104+)

The 5i22-1.5M and 7i43-200 are not tested, but are expected to work.


## Incorporating new upstream source

Primary development of the hostmot2 fpga firmware is done by Mesa Electronics, who releases source in .zip format.
This repository integrates that source with a Linux-centric build infrastructure to produce Debian packages.
When incorporating upstream changes from Mesa, the following procedure should be used:
 1. Put the new source code release on the "upstream" branch as a single large commit
 1. Merge upstream and master into a (possibly local) testing branch
 1. Make additional commits to add new card support, adjust for changed filenames, etc
 1. Test on a representative set of boards
 1. When the result of testing is satisfactory, merge to master branch.  Push new master and upstream branches to git.linuxcnc.org.

In the rare cases that we make a change to a .vhd, .pin, or other file that comes from Mesa, this strategy with an upstream branch lets us retain that change
(or have it appear as a merge conflict, if it cannot be automatically applied),
instead of losing it when we receive a new set of base source files.
