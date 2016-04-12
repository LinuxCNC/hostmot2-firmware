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

# Options used by Spartan 6 based designs with fallback space in eeprom
class BitgenCanFallback(Card):
    bitgen_extra = ['-g', 'next_config_register_write:disable',
        '-g', 'DebugBitstream:No', '-g', 'Binary:no', '-g', 'CRC:Enable',
        '-g', 'Reset_on_err:Yes', '-g', 'ConfigRate:26', '-g', 'ProgPin:PullUp',
        '-g', 'TckPin:PullUp', '-g', 'TdiPin:PullUp', '-g', 'TdoPin:PullUp',
        '-g', 'TmsPin:PullUp', '-g', 'UnusedPin:PullDown',
        '-g', 'UserID:0xFFFFFFFF', '-g', 'ExtMasterCclk_en:No',
        '-g', 'SPI_buswidth:1', '-g', 'TIMER_CFG:0xFFFF',
        '-g', 'multipin_wakeup:No', '-g', 'StartUpClk:CClk',
        '-g', 'DONE_cycle:6', '-g', 'GTS_cycle:5', '-g', 'GWE_cycle:4',
        '-g', 'LCK_cycle:NoWait', '-g', 'Security:None', '-g', 'DonePipe:No',
        '-g', 'DriveDone:No', '-g', 'en_sw_gsr:No', '-g', 'drive_awake:No',
        '-g', 'sw_clk:Startupclk', '-g', 'sw_gwe_cycle:5', '-g', 'sw_gts_cycle:4']


########################################################################
# Different toplevel files
class Top9030(BitgenSpecialOrder):
    topmodule = 'Top9030HostMot2'

class Top9054(BitgenSpecialOrder):
    topmodule = 'Top9054HostMot2'

class TopEPP(BitgenSpecialOrder):
    topmodule = 'TopEPPHostMot2'

class TopEPPS(Card):
    topmodule = 'TopEPPSHostMot2'

class TopSPI(Card):
    topmodule = 'TopGCSPIHostMot2'

class TopEth(Card):
    topmodule = 'TopEthernetHostMot2'
    topvhdl = 'TopEthernet16HostMot2'

class TopPCI(Card):
    topmodule = 'TopPCIHostMot2'
    topvhdl = 'TopPCIHostMot2'

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

class DBx2(Card):
    connectors = 2
    pins = 17*connectors

class DBx4(Card):
    connectors = 4
    pins = 17*connectors

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

class Spartan6_9_144(Card):
    chip = "xc6slx9-2tqg144"
    iseversions = (13,)

class Spartan6_16_256(Card):
    chip = "xc6slx16-ftg256-2"
    iseversions = (13,)

class Spartan6_25_256(Card):
    chip = "xc6slx25-ftg256-2"
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

class i80hd25(TopEth, HDx3, Spartan6_25_256, BitgenCanFallback):
    path = "7i80hd25"
    name = "i80hd_x25"
    card = "7i80hd"
    humanname = "Mesa 7i80 HD"

class i80db25(TopEth, DBx4, Spartan6_25_256, BitgenCanFallback):
    path = "7i80db25"
    name = "i80db_x25"
    card = "7i80db"
    humanname = "Mesa 7i80 DB"

class i80hd16(TopEth, HDx3, Spartan6_16_256, BitgenCanFallback):
    path = "7i80hd16"
    name = "i80hd_x16"
    card = "7i80hd"
    humanname = "Mesa 7i80 HD"

class i80db16(TopEth, DBx4, Spartan6_16_256, BitgenCanFallback):
    path = "7i80db16"
    name = "i80db_x16"
    card = "7i80db"
    humanname = "Mesa 7i80 DB"

class i90epp(TopEPPS, HDx3, Spartan6_9_144, BitgenCanFallback):
    path = "7i90epp"
    name = "i90_x9"
    card = "7i90"
    humanname = "Mesa 7i90 HD EPP"

class i90spi(TopSPI, HDx3, Spartan6_9_144, BitgenCanFallback):
    path = "7i90spi"
    name = "i90_x9"
    card = "7i90spi"
    humanname = "Mesa 7i90 HD SPI"

class i24(TopPCI, HDx3, Spartan6_16_256, BitgenCanFallback):
    path = "5i24"
    name = "i24_x16"
    card = "5i24"
    humanname = "Mesa 5i24"

class i25(TopPCI, DBx2, Spartan6_9_144, BitgenCanFallback):
    path = "5i25"
    name = "i25_x9"
    card = "5i25"
    humanname = "Mesa 5i25"

def get_card(name):
    return globals()[name]()
