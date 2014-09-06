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

# Card definitions
# Each specific card inherits from a number of base classes.
# 
# Typically, it inherits from three of them explicitly:
#  Toplevel (to define 'topmodule')
#  Connectors (to define 'connectors' and 'pins')
#  Chip (to define 'chip' and 'iseversions'
# And sometimes from:
#  Extra (to define 'bitgen_extra')
#
# and the card class itself must define:
#  name - the name of the card's vhdl file, without the "card.vhdl" suffix
#  path - the directory name for this card's bitfiles
#  card - the prefix of the bitfile name, and also the .ucf name
#  humanname - the name of the card for human consumption
#
# What's still missing is a way to define extra arguments based on ISE version

class Card(object):
    bitgen_extra = []

    # (Support for extra arguments on these steps can be added as necessary)
    #xst_extra = []
    #ngdbuild_extra = []
    #map_extra = []
    #par_extra = []

# Some cards need a special order specified in bitgen
class BitgenSpecialOrder(Card):
    bitgen_extra = ['-g', 'DONE_cycle:6', '-g', 'GWE_cycle:4',
         '-g', 'GTS_cycle:5', '-g', 'LCK_cycle:NoWait']


########################################################################
# Different toplevel files
class Top9030(BitgenSpecialOrder):
    topmodule = 'Top9030HostMot2'

class Top9054(BitgenSpecialOrder):
    topmodule = 'Top9054HostMot2'

class TopEPP(BitgenSpecialOrder):
    topmodule = 'TopEPPHostMot2'

########################################################################
# Different connector configurations
class HDx2(Card):
    connectors = 2
    pins = 48

class HDx3(Card):
    connectors = 3
    pins = 24*connectors

class HDx4(Card):
    connectors = 4
    pins = 24*connectors

class HDx6(Card):
    connectors = 6
    pins = 24*connectors

########################################################################
# Different FPGA chips
class Spartan2_200(Card):
    chip = "2s200pq208"
    iseversions = (10, 9)

class Spartan3_200_144(Card):
    chip = "3s400tq144"
    iseversions = (13, 10, 9)

class Spartan3_400_208(Card):
    chip = "3s400pq208"
    iseversions = (13, 10, 9)

class Spartan3_400_144(Card):
    chip = "3s400tq144"
    iseversions = (13, 10, 9)

class Spartan3_1000_320(Card):
    chip = "3s1000fg320"
    iseversions = (13, 10, 9)

class Spartan3_1000_456(Card):
    chip = "3s1000fg456"
    iseversions = (13, 10, 9)

class Spartan3_1500_320(Card):
    chip = "3s1500fg320"
    iseversions = (13, 10, 9)

class Spartan3_1500_456(Card):
    chip = "3s1500fg456"
    iseversions = (13, 10, 9)

class Spartan3_2000(Card):
    chip = "3s2000fg456"
    iseversions = (13,)

########################################################################
# The cards themselves
class i20(Top9030, HDx3, Spartan2_200):
    path = "5i20"
    name = "i20"
    card = "5i20"
    humanname = "Mesa 5i20"

class x20_1000(Top9054, HDx6, Spartan3_1000_456):
    path = "3x20-1"
    name = "x20_1000"
    card = "7i68"
    humanname = "Mesa 3x20-1"

class x20_1500(Top9054, HDx6, Spartan3_1500_456):
    path = "3x20-1.5"
    name = "x20_1500"
    card = "7i68"
    humanname = "Mesa 3x20-1.5"

class x20_2000(Top9054, HDx6, Spartan3_2000):
    path = "3x20-2"
    name = "x20_2000"
    card = "7i68"
    humanname = "Mesa 3x20-2"

class i22_1000(Top9054, HDx4, Spartan3_1000_320):
    path = "5i22-1"
    name = "i22_1000"
    card = "5i22"
    humanname = "Mesa 5i22-1"

class i22_1500(Top9054, HDx4, Spartan3_1500_320):
    path = "5i22-1.5"
    name = "i22_1500"
    card = "5i22"
    humanname = "Mesa 5i22-1.5"

class i23(Top9054, HDx3, Spartan3_400_208):
    path = "5i23"
    name = "i23"
    card = "5i23"
    humanname = "Mesa 5i23"

class i68(Top9054, HDx3, Spartan3_400_208):
    path = "4i68"
    name = "i68"
    card = "4i68"
    humanname = "Mesa 4i68"

class i43_400(TopEPP, HDx2, Spartan3_400_144):
    path = "7i43-4"
    name = "i43_400"
    card = "7i43"
    humanname = "Mesa 7i43-4"

class i43_200(TopEPP, HDx2, Spartan3_200_144):
    path = "7i43-2"
    name = "i43_200"
    card = "7i43"
    humanname = "Mesa 7i43-2"

class i65(Top9030, HDx3, Spartan2_200):
    path = "4i65"
    name = "i65"
    card = "4i65"
    humanname = "Mesa 4i65"

def get_card(name):
    return globals()[name]()
