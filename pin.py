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
from iselib import *

card = sys.argv[1]
card = cards.get_card(card)
pinvhdl = sys.argv[2]
cardvhdl = card.name + "card"

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

sources = [
    'IDROMConst.vhd', 'idrom_tools.vhd', 'PIN_%s.vhd' % pinvhdl,
    '%s.vhd' % cardvhdl, p("pinmaker.vhd")]
sources = [os.path.abspath(s) for s in sources]
subst(sys.argv[3], p("pinmaker.vhd"), PIN=pinvhdl, CARD=cardvhdl, OUT=os.path.abspath(sys.argv[4]))

use_ise((13,10,9))

with open(p("prj"), "wt") as f:
    for s in sources:
        print >>f, "vhdl work", s
with open(p("scr"), "wt") as f:
    print >>f, "run all\nexit"

os.chdir(d)
run("fuse", "-prj", "prj", "-o", "main", "pinmaker_%s" % pinvhdl)
run("./main", "-tclbatch", "scr")
