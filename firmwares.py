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
import os

sz = {
    'i20': 72,
    'i22_1000': 96,
    'i22_1500': 96,
    'i23': 72,
    'i43_200': 48,
    'i43_400': 48,
    'i65': 72,
    'i68': 72,
    'x20_1000': 144,
    'x20_1500': 144,
    'x20_2000': 144,
}

path = {
    'i20': '5i20',
    'i22_1000': '5i22-1',
    'i22_1500': '5i22-1.5',
    'i23': '5i23',
    'i43_200': '7i43-2',
    'i43_400': '7i43-4',
    'i65': '4i65',
    'i68': '4i68',
    'x20_1000': '3x20-1',
    'x20_1500': '3x20-1.5',
    'x20_2000': '3x20-2',
}
def existing(*names):
    for n in names:
        if os.path.isfile(n): return n
    raise IOError, "Could not find a candidate from %r" % (names,)

def pin(chip, fw):
    if fw.endswith("B") or fw.endswith("S"): fw = fw[:-1]
    return existing("PIN_%s.vhd" % fw, "PIN_%s_%d.vhd" % (fw, sz[chip]))[4:-4]

def gen(chip, fw):
    print "$(eval $(call FIRMWARE_template,fw/%s/%s,%s,%s))" % (
        path[chip], fw, chip, pin(chip, fw))

all_chips = []
for line in open("firmwares.txt"):
    line = line.strip()
    if not line or line.startswith("#"): continue
    line = line.split()
    chip = line[0]
    if chip not in all_chips: all_chips.append(chip)
    for fw in line[1:]:
        gen(chip, fw)

for chip in all_chips:
    print "$(eval $(call CHIP_template,%s))" % chip
