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
import sys

import cards

def existing(*names):
    for n in names:
        if os.path.isfile("src/" + n): return n
    raise IOError, "Could not find a candidate from %r" % (names,)

def pin(card, fw):
    if fw.endswith("B") or fw.endswith("S"): fw = fw[:-1]
    return existing("PIN_%s.vhd" % fw, "PIN_%s_%d.vhd" % (fw, card.pins))[4:-4]

def gen(card, fw):
    print "$(eval $(call FIRMWARE_template,fw/%s/%s,%s,%s,%s))" % (
        card.path, fw, card.__name__, pin(card, fw), card.path)
all_cards = []
for line in open(sys.argv[1]):
    line = line.strip()
    if not line or line.startswith("#"): continue
    line = line.split()
    card = line[0]
    if card not in all_cards: all_cards.append(card)
    card = getattr(cards, card)
    for fw in line[1:]:
        gen(card, fw)

for card in all_cards:
    card = cards.get_card(card)
    print "$(eval $(call CARD_template,%s))" % card.path
