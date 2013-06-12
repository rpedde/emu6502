# emu6502 #

An attempt to synthesize a custom 6502 machine by someone with no
business doing logic design.  Please close your eyes before looking at
this.

This utilizes the opencores T65 core, as modified by the FPGAArcade
folks, as well as some stuff USB debugging stuff from Xess
(http://www.xess.com), as it is targetted at a Xess XuLA-200.

Be aware, though, that this is NOT an example of How To Do It.

## Notes to self ##

To upload to XuLA on Linux, need xstools (I'm using 0.1.0 in a venv,
which pulled in pyusb, pygments, mechanize, bitarray, and intelhex).
I'm pretty sure I actually got it from pypi.  There were issues with
system pyusb, as the xstools require pyusb > 1.0 and it wasn't in
debian wheezy.

Anywa, this gives us xsload.py, which can upload bitstreams.

xsload.py jtag loads the bitstream, it does not permanently send to
config flash.  That is, it's gone on reboot.

### JTAG upload ###
xsload.py -f <bitstream>

Configuration options:
 -g ConfigRate 12
 all pins pullup
 unused float

Startup Options
 -g StartUpClk JTAG Clock
 -g DonePipe True
 -g DriveDone False

### Config upload ###

Hrm... have to use a different tool, can't remember what it is.  :)
