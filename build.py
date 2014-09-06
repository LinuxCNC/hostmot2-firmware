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
import time

common_vhdl = [
    'IDROMConst.vhd',

    'atrans.vhd',
    'adpram.vhd',
    'biss.vhd',
    'boutreg.vhd',
    'bufferedspi.vhd',
    'PinExists.vhd',
    'CountPinsInRange.vhd',
    'd8o8.vhd',
    'dpll.vhd',
    'fanucabs.vhd',
    'hmtimers.vhd',
    'hostmotid.vhd',
    'idrom.vhd',
    'irqlogic.vhd',
    'irqlogics.vhd',
    'InputPinsPerModule.vhd',
    'kubstepgenz.vhd',
    'MaxPinsPerModule.vhd',
    'NumberOfModules.vhd',
    'pktuartr.vhd',
    'pktuartx.vhd',
    'pwmpdmgenh.vhd',
    'pwmrefh.vhd',
    'qcounterate.vhd',
    'qcountersfp.vhd',
    'qcountersf.vhd',
    'qcounteratesk.vhd',
    'scalercounter.vhd',
    'scalertimer.vhd',
    'simplespi8.vhd',
    'simplespix.vhd',
    'simplessi.vhd',
    'srl16delay.vhd',
    'sslbpram.vhd',
    'testram.vhd',
    'testrom.vhd',
    'threephasepwm.vhd',
    'timestamp.vhd',
    'uartr8.vhd',
    'uartr.vhd',
    'uartx8.vhd',
    'uartx.vhd',
    'ubrategen.vhd',
    'usbram.vhd',
    'usbrom.vhd',
    'watchdog.vhd',
    'wordpr.vhd',
    'wordrb.vhd',

    'MaxIOPinsPerModule.vhd',
    'MaxInputPinsPerModule.vhd',
    'MaxOutputPinsPerModule.vhd',
    'ModuleExists.vhd',
    'OutputInteg.vhd',
    'b32qcondmac2w.vhd',
    'binosc.vhd',
    'd8o8sq.vhd',
    'd8o8sqw.vhd',
    'd8o8sqws.vhd',
    'daqfifo16.vhd',
    'decodedstrobe.vhd',
    'dpram.vhd',
    'drqlogic.vhd',
    'kubstepgenzi.vhd',
    'log2.vhd',
    'oneofndecode.vhd',
    'resolver.vhd',
    'resolverdaq2.vhd',
    'resrom.vhd',
    'resroms.vhd',
    'sine16.vhd',
    'sserial.vhd',
    'sserialwa.vhd',
    'sslbprom.vhd',
    'syncwavegen.vhd',
    'twiddle.vhd',
    'twidrom.vhd',
    'wavegen.vhd',
    'waveram.vhd',

    'hostmot2.vhd'
]

card2chip = {
    'i20': '2s200pq208',
    'i22_1000': '3s1000fg320',
    'i22_1500': '3s1500fg320',
    'i23': '3s400pq208',
    'i43_200': '3s200tq144',
    'i43_400': '3s400tq144',
    'i65': '2s200pq208',
    'i68': '3s400pq208',
    'x20_1000': '3s1000fg456',
    'x20_1500': '3s1500fg456',
    'x20_2000': '3s2000fg456',
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
    'x20_1000': '9054',
    'x20_1500': '9054',
    'x20_2000': '9054',
}

# list the preferred versions of ise for each card type
# list entries can be the name of the settings.sh file to use (specify an
# absolute path), or a Xilinx version number (and this build script will
# try the default install location for that version)
# ISE 10 is the last one that supports the Spartan2 FPGA (in the 5i20 and 4i65)
# FIXME: should this be by chip type instead?
card2ise = {  # have to fill out the rest of this stupid table...
    'i20': (10, 9),
    'i65': (10, 9),

    'x20_2000': (13, 10),
    'x20_1000': (13, 10, 9),
    'i22_1500': (13, 10, 9),
    'i22_1000': (13, 10, 9),
    'i23':      (13, 10, 9),
    'i68':      (13, 10, 9),
    'i43_400':  (13, 10, 9),
    'i43_200':  (13, 10, 9)
}

# done - 6
# enable outputs - 5
# release write enable - 4
bitgen_extra = {
    'epp': ['-g', 'DONE_cycle:6', '-g', 'GWE_cycle:4', '-g', 'GTS_cycle:5', '-g', 'LCK_cycle:NoWait'],
    '9054': ['-g', 'DONE_cycle:6', '-g', 'GWE_cycle:4', '-g', 'GTS_cycle:5', '-g', 'LCK_cycle:NoWait'],
    '9030': ['-g', 'DONE_cycle:6', '-g', 'GWE_cycle:4', '-g', 'GTS_cycle:5', '-g', 'LCK_cycle:NoWait'],
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
    'x20_1000': '7i68',
    'x20_1500': '7i68',
    'x20_2000': '7i68',
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

def usage(hint='', card=''):
    usage =  __doc__ % sys.argv[0] + help_cards() + help_pins(card)
    if hint: usage += "\n" + hint
    raise SystemExit, usage

def subst(in_, out, **kw):
    def rfn(m):
        g = m.group(1)
        if g == '': return '@'
        return kw[g.upper()]
    r = re.compile("@([^@]*)@")
    s = open(in_).read()
    s = r.sub(rfn, s)
    open(out, "w").write(s)

_sq_whitelist = string.lowercase + string.uppercase + string.digits + ".-_/"
def sq(a):
    if not a.strip(_sq_whitelist):
        return a
    return "'" + a.replace("'", "'\\''") + "'"

timing = []

def run(*args):
    cmd = " ".join(sq(a) for a in args)
    # xilinx 13.3's settings32.sh uses bashisms
    if settings_sh: cmd = "bash -c '. %s; %s'" % (settings_sh, cmd)
    print "#", cmd
    sys.stdout.flush()
    t0 = time.time()
    r = os.system(cmd)
    print "# exited with", r; sys.stdout.flush()
    t1 = time.time()
    timing.append((args[0], (t1-t0)))
    if r:
        raise SystemExit, os.WEXITSTATUS(r) or 1

def mkdir(a):
    if not os.path.isdir(a): os.mkdir(a)

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

# Xilinx Webpack 10.1 and 13.3 both install into /opt/Xilinx/,
# into 10.1/ and 13.3/.
# 10.1's settings are in ISE/settings32.sh
# 13.3's settings are in ISE_DS/settings32.sh
if 'XILINX' in os.environ:
    print "XILINX environment variable already set, not overriding"
else:
    for ise in card2ise[card]:
        if os.path.exists(str(ise)):
            settings_sh = str(ise)
            break

        files = glob.glob('/opt/Xilinx/%s/*/settings32.sh' % ise)
        if len(files) > 1:
            print "multiple settings files found!", files
            raise SystemExit, 1
        if len(files) == 1:
            settings_sh = files[0]
            break

        files = glob.glob('/opt/Xilinx/%s.*/*/settings32.sh' % ise)
        if len(files) == 1:
            settings_sh = files[0]
            break
        if len(files) > 1:
            # use the newest one: sort by minor version since the major versions are all the same
            files = sorted(files, key=lambda f: int((f.split('/')[3]).split('.')[1]))
            settings_sh = files[-1]
            break

    else:
        usage("Firmware requires one of these ise major versions to build: %s"
                % " ".join(map(str, card2ise[card])))

    print "using Xilinx Webpack settings '%s'" % settings_sh

d = os.path.splitext(outfile)[0] + "_work"
print "# workdir", sq(d)
if not os.path.isdir(d): os.makedirs(d)

orgdir = os.getcwd()
def s(*x): return os.path.join(orgdir, *x)
def p(*x): return os.path.join(d, *x)

constraints = s("%s.ucf" % card2card[card])

cardvhdl = card+"card"
pinvhdl = "PIN_" + pin
topfile_in = '%s.vhd.in' % card2top[card]
topfile_out = os.path.splitext(outfile)[0] + ".vhd"
subst(topfile_in, topfile_out, CARD=cardvhdl, PIN=pinvhdl);

all_vhdl = common_vhdl + [cardvhdl + '.vhd', pinvhdl + '.vhd', topfile_out]
all_vhdl = [s(f) for f in all_vhdl]

# Run everything from the temporary directory
os.chdir(d)

# Build directories
mkdir("tmp_syn")
mkdir("work_syn")

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

def report_timing():
    for k, v in timing:
        m, s = divmod(v, 60)
        print "%d:%04.1f-%-11s" % (m, s, k),
    print

try:
    # Synthesis
    run("xst", "-ifn", "scr")

    # ngdbuild
    run("ngdbuild", "-uc", constraints, "work.ngc")

    # Mapping
    run("map", "work.ngd")

    # Placing / routing
    run("par", "-w", "work.ncd", "work.ncd", "work.pcf")

    # Bitgen
    bitgen_args = bitgen_extra.get(card2top[card], []) + ["work.ncd", "work.bit", "work.pcf"]
    run("bitgen", "-w", *bitgen_args) 

    shutil.copy("work.bit", outfile)
finally:
    report_timing()

# Copy out other interesting logfiles?
