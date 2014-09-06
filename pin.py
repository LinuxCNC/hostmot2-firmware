#!/usr/bin/python
# coding=utf-8
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
import os
import shutil
import string
import sys
import re
import tempfile
import cards

card = sys.argv[1]
card = cards.get_card(card)
pinvhdl = sys.argv[2]
cardvhdl = card.name + "card"

_sq_whitelist = string.lowercase + string.uppercase + string.digits + ".-_/"
def sq(a):
    if not a.strip(_sq_whitelist):
        return a
    return "'" + a.replace("'", "'\\''") + "'"

def run(*args):
    print >>sys.stderr, "#", " ".join([sq(a) for a in args])
    r = os.spawnvp(os.P_WAIT, args[0], args)
    print >>sys.stderr, "# exited with", r
    if r:
        raise SystemExit, r

def p(*x): return os.path.join(d, *x)

def subst(in_, out, **kw):
    def rfn(m):
        g = m.group(1)
        if g == '': return '@'
        return kw[g.upper()]
    r = re.compile("@([^@]*)@")
    s = open(in_).read()
    s = r.sub(rfn, s)
    open(out, "w").write(s)

d = tempfile.mkdtemp(prefix='hm2')
print >>sys.stderr, "# tempdir", sq(d)
atexit.register(shutil.rmtree, d)

shutil.copy("IDROMConst.vhd", p("IDROMConst.vhd"))
shutil.copy("idrom_tools.vhd", p("idrom_tools.vhd"))
shutil.copy("PIN_%s.vhd" % pinvhdl, p("PIN_%s.vhd") % pinvhdl)
shutil.copy("%s.vhd" % cardvhdl, p("%s.vhd") % cardvhdl)
subst("pinmaker.vhd.in", p("pinmaker_%s.vhd") % pinvhdl,
    PIN=pinvhdl, CARD=cardvhdl)

orgdir = os.getcwd()
os.chdir(d)
run("ghdl", "-a", "-fexplicit", "--ieee=synopsys",
    "IDROMConst.vhd",
    "idrom_tools.vhd",
    "PIN_%s.vhd" % pinvhdl,
    "%s.vhd" % cardvhdl,
    "pinmaker_%s.vhd" % pinvhdl)
run("ghdl", "-e", "-fexplicit", "--ieee=synopsys", "pinmaker_%s" % pinvhdl)
run("ghdl", "-r", "pinmaker_%s" % pinvhdl)
