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
import cards

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
    'parity.vhd',
    'decodedstrobe2.vhd',

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
    'fixicap.vhd',
    'd16w.vhd',
    'etherhm2.vhd',

    'hostmot2.vhd'
]

def help_cards():
    available = sorted(card.__name__ for card in cards.__dict__.values() if hasattr(card, 'name'))
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
try:
    card = cards.get_card(card)
except KeyError:
    usage("Unknown card %r" % card)

if not os.path.exists("PIN_" + pin + ".vhd"):
    usage("Unknown pin configuration %r" % pin, card)

orgdir = os.getcwd()
if len(sys.argv) == 4:
    outfile = os.path.join(orgdir, sys.argv[3])
else:
    outfile = os.path.join(orgdir, "%s_%s.BIT"% (card.card, pin))

def guess_ise_version():
    with os.popen("map -h | head -1") as p:
        info = p.read()
        info = info.split()[1].split(".")[0]
        try:
            return int(info)
        except:
            return None

# Xilinx Webpack 10.1 and 13.3 both install into /opt/Xilinx/,
# into 10.1/ and 13.3/.
# 10.1's settings are in ISE/settings32.sh
# 13.3's settings are in ISE_DS/settings32.sh
if 'XILINX' in os.environ:
    print "XILINX environment variable already set, not overriding"
    ise = guess_ise_version()
else:
    for ise in card.iseversions:
        localsettings = os.path.abspath("settings%d.sh" % ise)
        if os.path.exists(localsettings):
            if os.path.islink(localsettings): localsettings = os.readlink(localsettings)
            settings_sh = localsettings
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
                % " ".join(map(str, card.iseversions)))

    print "using Xilinx Webpack settings '%s'" % settings_sh

d = os.path.splitext(outfile)[0] + "_work"
print "# workdir", sq(d)
if not os.path.isdir(d): os.makedirs(d)

orgdir = os.getcwd()
def s(*x): return os.path.join(orgdir, *x)
def p(*x): return os.path.join(d, *x)

constraints = s("%s.ucf" % card.card)

cardvhdl = card.name+"card"
pinvhdl = "PIN_" + pin
topfile_in = (getattr(card, 'topvhdl', '') or getattr(card, 'topmodule', '')) + ".vhd"
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
-top %s
-ofmt ngc -ofn work.ngc
-p %s
""" % (card.topmodule, card.chip))

# top, card, pin
prjf = open("prj", "w")
for f in all_vhdl: prjf.write("vhdl work %s\n" % f)
prjf.close()

def report_timing():
    t = 0
    for k, v in timing:
        t += v
        m, s = divmod(v, 60)
        print "%d:%04.1f-%-11s" % (m, s, k),
    print "%d:%04.1f-total" % (m, s)
    print

try:
    # Synthesis
    run("xst", '-intstyle', 'ise', "-ifn", "scr")

    # ngdbuild
    run("ngdbuild", '-intstyle', 'ise', "-uc", constraints, "work.ngc")

    if os.path.exists('work.ncd'):
        os.unlink('work.ncd')

    # Mapping
    run("map", '-intstyle', 'ise', "work.ngd")

    # Placing / routing
    run("par", '-intstyle', 'ise', "-w", "work.ncd", "work.ncd", "work.pcf")

    # Bitgen
    bitgen_args = card.bitgen_extra + ["work.ncd", "work.bit", "work.pcf"]
    run("bitgen", '-intstyle', 'ise', "-w", *bitgen_args) 

    shutil.copy("work.bit", outfile)
finally:
    report_timing()

# Copy out other interesting logfiles?
