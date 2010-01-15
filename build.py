#!/usr/bin/python
# coding=utf-8
"""build.py: build a hostmot2 firmware

Usage: %s cardname pinname ?bitfilename?

If bitfilename isn't specified, it is based on the cardname and pinname.
"""
#    build hostmot2 firmwares
#    Copyright © 2009 Jeff Epler <jepler@unpythonic.net>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

import atexit
import glob
import os
import re
import shutil
import string
import sys
import tempfile
import textwrap

common_vhdl = """
IDROMConst.vhd
atrans.vhd boutreg.vhd bufferedspi.vhd
PinExists.vhd CountPinsInRange.vhd d8o8.vhd dpll.vhd hostmotid.vhd
idrom.vhd irqlogic.vhd kubstepgenz.vhd MaxPinsPerModule.vhd
NumberOfModules.vhd pwmpdmgenh.vhd pwmrefh.vhd qcounterate.vhd qcountersfp.vhd
qcountersf.vhd simplespi8.vhd simplespix.vhd simplessi.vhd testram.vhd
testrom.vhd threephasepwm.vhd timestamp.vhd uartr8.vhd uartr.vhd uartx8.vhd
uartx.vhd ubrategen.vhd usbram.vhd usbrom.vhd watchdog.vhd wordpr.vhd
wordrb.vhd
hostmot2.vhd

 """.split()

card2chip = {
    'i20': '2s200pq208',
    'i22_1000': '3s1000fg320',
    'i22_1500': '3s1500fg320',
    'i23': '3s400pq208',
    'i43_200': '3s200tq144',
    'i43_400': '3s400tq144',
    'i65': '2s200pq208',
    'i68': '3s400pq208',
}

card2top = {
    'i20': '9030',
    'i22_1000': '9054',
    'i22_1500': '9054',
    'i23': '9054',
    'i43_200': 'epp',
    'i43_400': 'epp',
    'i65': '9030',
    'i68': '9054',
}

card2card = {
    'i20': '5i20',
    'i22_1000': '5i22',
    'i22_1500': '5i22',
    'i23': '5i23',
    'i43_200': '7i43',
    'i43_400': '7i43',
    'i65': '4i65',
    'i68': '4i68',
}

def help_cards():
    available = sorted(card2card.keys())
    return "\n" + "\n".join(
        textwrap.wrap("Available cards: " + " ".join(available),
            subsequent_indent=" "*8)) + "\n"

def help_pins(card):
    available = sorted(s[4:-4] for s in glob.glob("PIN_*.vhd"))
    return "\n" + "\n".join(
        textwrap.wrap("Available pinouts: " + " ".join(available),
            subsequent_indent=" "*8)) + "\n"

def help_env():
    return "\nYou must 'source settings.sh' before running this program\n"

def usage(hint='', card=''):
    usage =  __doc__ % sys.argv[0] + help_cards() + help_pins(card) + help_env()
    if hint: usage += "\n" + hint
    raise SystemExit, usage

def subst(in_, out, **kw):
    def rfn(m):
        g = m.group(1)
        if g == '': return '@'
        return kw[g]
    r = re.compile("@([^@]*)@")
    s = open(in_).read()
    s = r.sub(rfn, s)
    open(out, "w").write(s)

_sq_whitelist = string.lowercase + string.uppercase + string.digits + ".-_/"
def sq(a):
    if not a.strip(_sq_whitelist):
        return a
    return "'" + a.replace("'", "'\\''") + "'"

def run(*args):
    print "#", " ".join([sq(a) for a in args])
    r = os.spawnvp(os.P_WAIT, args[0], args)
    print "# exited with", r
    if r:
        raise SystemExit, r

if 'XILINX' not in os.environ:
    usage("Xilinx environment not availble")

if len(sys.argv) != 3 and len(sys.argv) != 4:
    usage("Wrong # arguments")
    usage()

card, pin = sys.argv[1:3]
if card not in card2card:
    usage("Uknown card %r" % card)

if not os.path.exists("PIN_" + pin + ".vhd"):
    usage("Unknown pin configuration %r" % pin, card)

orgdir = os.getcwd()
if len(sys.argv) == 4:
    outfile = os.path.join(orgdir, sys.argv[3])
else:
    outfile = os.path.join(orgdir, "%s_%s.BIT"% (card2card[card], pin))

d = tempfile.mkdtemp(prefix='hm2')
print "# tempdir", sq(d)
atexit.register(shutil.rmtree, d)

def p(*x): return os.path.join(d, *x)

for i in glob.glob("*.vhd"):  # assume spare vhdl files cause no trouble
    shutil.copy(i, p(i))
shutil.copy("%s.ucf" % card2card[card], p("constraints.ucf"))

cardvhdl = card+"card"
pinvhdl = "PIN_" + pin
subst('%s.vhd.in' % card2top[card], p("top.vhd"), CARD=cardvhdl, PIN=pinvhdl);

all_vhdl =  common_vhdl + [cardvhdl + '.vhd', pinvhdl + '.vhd', "top.vhd"]

# Run everything from the temporary directory
orgdir = os.getcwd()
os.chdir(d)

# Build directories
os.mkdir("tmp_syn")
os.mkdir("work_syn")

# Build vscr, vprj
open("scr", "w").write("""
set -tmpdir ./tmp_syn
set -xsthdpdir ./work_syn
run
-opt_mode Speed -opt_level 1
-ifmt mixed -ifn prj
-top top
-ofmt ngc -ofn work.ngc
-p %s
""" % card2chip[card])

# top, card, pin
prjf = open("prj", "w")
for f in all_vhdl: prjf.write("vhdl work %s\n" % f)
prjf.close()

# Synthesis
run("xst", "-ifn", "scr")

# ngdbuild
run("ngdbuild", "-uc", "constraints.ucf", "work.ngc")

# Mapping
run("map", "work.ngd")

# Placing / routing
run("par", "-w", "work.ncd", "work.ncd", "work.pcf")

# Bitgen
run("bitgen", "work.ncd", "work.bit", "work.pcf")

shutil.copy("work.bit", outfile)

# Copy out other interesting logfiles?
