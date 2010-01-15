library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_UNSIGNED.ALL;
use IEEE.std_logic_ARITH.ALL;
--
-- Copyright (C) 2009, Peter C. Wallace, Mesa Electronics
-- http://www.mesanet.com
--
-- This program is is licensed under a disjunctive dual license giving you
-- the choice of one of the two following sets of free software/open source
-- licensing terms:
--
--    * GNU General Public License (GPL), version 2.0 or later
--    * 3-clause BSD License
-- 
--
-- The GNU GPL License:
-- 
--     This program is free software; you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation; either version 2 of the License, or
--     (at your option) any later version.
-- 
--     This program is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
-- 
--     You should have received a copy of the GNU General Public License
--     along with this program; if not, write to the Free Software
--     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
-- 
-- 
-- The 3-clause BSD License:
-- 
--     Redistribution and use in source and binary forms, with or without
--     modification, are permitted provided that the following conditions
--     are met:
-- 
--         * Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
-- 
--         * Redistributions in binary form must reproduce the above
--           copyright notice, this list of conditions and the following
--           disclaimer in the documentation and/or other materials
--           provided with the distribution.
-- 
--         * Neither the name of Mesa Electronics nor the names of its
--           contributors may be used to endorse or promote products
--           derived from this software without specific prior written
--           permission.
-- 
-- 
-- Disclaimer:
-- 
--     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--     COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--     BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--     LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--     ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--     POSSIBILITY OF SUCH DAMAGE.
-- 

package IDROMConst is

	constant QCountRev : std_logic_vector(7 downto 0) := x"02";
	constant KUBStepGenRev : std_logic_vector(7 downto 0) := x"02";
	
	constant NullAddr : std_logic_vector(7 downto 0) := x"00";
	constant ReadIDAddr : std_logic_vector(7 downto 0) := x"01";
	constant LEDAddr : std_logic_vector(7 downto 0) := x"02";	
	constant LEDNumRegs : std_logic_vector(7 downto 0) := x"01";
	constant LEDMPBitMask : std_logic_vector(31 downto 0) := x"00000000";

	constant IDROMAddr : std_logic_vector(7 downto 0) := x"04";
	constant Cookie : std_logic_vector(31 downto 0) := x"55AACAFE";
	constant HostMotNameLow : std_logic_vector(31 downto 0) := x"54534F48"; 	-- HOST
	constant HostMotNameHigh : std_logic_vector(31 downto 0) := x"32544F4D"; 	-- MOT2
	
	constant BoardNameMesa : std_logic_vector(31 downto 0) := x"4153454D";		-- MESA
	constant BoardName4I65 : std_logic_vector(31 downto 0) := x"35364934";		-- 4I65
	constant BoardName4I68 : std_logic_vector(31 downto 0) := x"38364934";		-- 4I68
	constant BoardName5I20 : std_logic_vector(31 downto 0) := x"30324935";		-- 5I20
	constant BoardName5I22 : std_logic_vector(31 downto 0) := x"32324935";		-- 5I22
	constant BoardName5I23 : std_logic_vector(31 downto 0) := x"33324935";		-- 5I23
	constant BoardName7I43 : std_logic_vector(31 downto 0) := x"33344937";		-- 7I43
	constant BoardName7I60 : std_logic_vector(31 downto 0) := x"30364937";		-- 7I60
	constant BoardName3X20 : std_logic_vector(31 downto 0) := x"30325833";		-- 3X20
	
	constant IDROMOffset : std_logic_vector(31 downto 0) := x"0000"&IDROMAddr&x"00"; -- note need to change if pitch changed
	constant IDROMWEnAddr : std_logic_vector(7 downto 0) := x"08";

	constant IRQDivAddr  : std_logic_vector(7 downto 0) := x"09";
	constant IRQStatusAddr : std_logic_vector(7 downto 0) := x"0A";
	constant ClearIRQAddr : std_logic_vector(7 downto 0) := x"0B"; 
	constant IRQNumRegs : std_logic_vector(7 downto 0) := x"03";
	constant IRQMPBitMask : std_logic_vector(31 downto 0) := x"00000000";
	
	constant WatchdogTimeAddr : std_logic_vector(7 downto 0) := x"0C";
	constant WatchDogStatusAddr : std_logic_vector(7 downto 0) := x"0D";
	constant WatchDogCookieAddr : std_logic_vector(7 downto 0) := x"0E";
	constant WatchDogNumRegs : std_logic_vector(7 downto 0) := x"03";
	constant WatchDogMPBitMask : std_logic_vector(31 downto 0) := x"00000000";

	constant	PortAddr : std_logic_vector(7 downto 0) := x"10";
	constant	DDRAddr : std_logic_vector(7 downto 0) := x"11";	
	constant	AltDataSrcAddr : std_logic_vector(7 downto 0) := x"12";
	constant	OpenDrainModeAddr : std_logic_vector(7 downto 0) := x"13";		
	constant OutputInvAddr : std_logic_vector(7 downto 0) := x"14";	
	constant IOPortNumRegs : std_logic_vector(7 downto 0) := x"05";
	constant IOPortMPBitMask : std_logic_vector(31 downto 0) := x"0000001F";

	constant StepGenRateAddr : std_logic_vector(7 downto 0) := x"20";	
	constant StepGenAccumAddr : std_logic_vector(7 downto 0) := x"21";		
	constant StepGenModeAddr : std_logic_vector(7 downto 0) := x"22";
	constant StepGenDSUTimeAddr : std_logic_vector(7 downto 0) := x"23";
	constant StepGenDHLDTimeAddr : std_logic_vector(7 downto 0) := x"24";
	constant StepGenPulseATimeAddr : std_logic_vector(7 downto 0) := x"25";
	constant StepGenPulseITimeAddr : std_logic_vector(7 downto 0) := x"26";
	constant StepGenTableAddr : std_logic_vector(7 downto 0) := x"27";
	constant StepGenTableMaxAddr : std_logic_vector(7 downto 0) := x"28";
	constant StepGenBasicRateAddr : std_logic_vector(7 downto 0) := x"29";
	constant StepGenNumRegs : std_logic_vector(7 downto 0) := x"0A";
	constant StepGenMPBitMask : std_logic_vector(31 downto 0) := x"000001FF";

	constant QCounterAddr : std_logic_vector(7 downto 0) := x"30";
	constant QCounterCCRAddr : std_logic_vector(7 downto 0) := x"31";
	constant TSDivAddr : std_logic_vector(7 downto 0) := x"32";
	constant TSAddr : std_logic_vector(7 downto 0) := x"33";
	constant QCRateAddr : std_logic_vector(7 downto 0) := x"34";
	constant QCounterNumRegs : std_logic_vector(7 downto 0) := x"05";
	constant QCounterMPBitMask : std_logic_vector(31 downto 0) := x"00000003";

	constant MuxedQCounterAddr : std_logic_vector(7 downto 0) := x"35";
	constant MuxedQCounterCCRAddr : std_logic_vector(7 downto 0) := x"36";
	constant MuxedTSDivAddr : std_logic_vector(7 downto 0) := x"37";
	constant MuxedTSAddr : std_logic_vector(7 downto 0) := x"38";
	constant MuxedQCRateAddr : std_logic_vector(7 downto 0) := x"39";
	constant MuxedQCounterNumRegs : std_logic_vector(7 downto 0) := x"05";
	constant MuxedQCounterMPBitMask : std_logic_vector(31 downto 0) := x"00000003";

	constant PWMValAddr : std_logic_vector(7 downto 0) := x"40";
	constant PWMCRAddr : std_logic_vector(7 downto 0) := x"41";
	constant PWMRateAddr : std_logic_vector(7 downto 0) := x"42";
	constant PDMRateAddr : std_logic_vector(7 downto 0) := x"43";
	constant PWMEnasAddr : std_logic_vector(7 downto 0) := x"44";
	constant PWMNumRegs : std_logic_vector(7 downto 0) := x"05";
	constant PWMMPBitMask : std_logic_vector(31 downto 0) := x"00000003";

	constant TPPWMValAddr : std_logic_vector(7 downto 0) := x"45";
	constant TPPWMEnaAddr : std_logic_vector(7 downto 0) := x"46";
	constant TPPWMDZAddr : std_logic_vector(7 downto 0) := x"47";
	constant TPPWMRateAddr : std_logic_vector(7 downto 0) := x"48";
	constant TPPWMNumRegs : std_logic_vector(7 downto 0) := x"04";
	constant TPPWMMPBitMask : std_logic_vector(31 downto 0) := x"00000003";

	constant SPIDataAddr : std_logic_vector(7 downto 0) := x"50";
	constant SPIBitCountAddr : std_logic_vector(7 downto 0) := x"51";
	constant SPIBitrateAddr : std_logic_vector(7 downto 0) := x"52";
	constant SPINumRegs : std_logic_vector(7 downto 0) := x"03";
	constant SPIMPBitMask : std_logic_vector(31 downto 0) := x"00000007";

	constant BSPIDataAddr : std_logic_vector(7 downto 0) := x"54";
	constant BSPIDescriptorAddr : std_logic_vector(7 downto 0) := x"55";
	constant BSPIFIFOCountAddr : std_logic_vector(7 downto 0) := x"56";
	constant BSPINumRegs : std_logic_vector(7 downto 0) := x"03";
	constant BSPIMPBitMask : std_logic_vector(31 downto 0) := x"00000007";

	constant DBSPIDataAddr : std_logic_vector(7 downto 0) := x"58";
	constant DBSPIDescriptorAddr : std_logic_vector(7 downto 0) := x"59";
	constant DBSPIFIFOCountAddr : std_logic_vector(7 downto 0) := x"5A";
	constant DBSPINumRegs : std_logic_vector(7 downto 0) := x"03";
	constant DBSPIMPBitMask : std_logic_vector(31 downto 0) := x"00000007";
	
	constant UARTTDataAddr : std_logic_vector(7 downto 0) := x"60";	
	constant UARTTFIFOCountAddr : std_logic_vector(7 downto 0) := x"61";
	constant UARTTBitrateAddr: std_logic_vector(7 downto 0) := x"62";
	constant UARTTModeRegAddr : std_logic_vector(7 downto 0) := x"63";	
	constant UARTTNumRegs : std_logic_vector(7 downto 0) := x"04";
	constant UARTTMPBitMask : std_logic_vector(31 downto 0) := x"0000000F";

	constant UARTRDataAddr : std_logic_vector(7 downto 0) := x"64";
	constant UARTRFIFOCountAddr : std_logic_vector(7 downto 0) := x"65";
	constant UARTRBitrateAddr : std_logic_vector(7 downto 0) := x"66";
	constant UARTRModeRegAddr : std_logic_vector(7 downto 0) := x"67";
	constant UARTRNumRegs : std_logic_vector(7 downto 0) := x"04";
	constant UARTRMPBitMask : std_logic_vector(31 downto 0) := x"0000000F";

	constant SSSIDataAddr : std_logic_vector(7 downto 0) := x"68";
	constant SSSIBitCountAddr : std_logic_vector(7 downto 0) := x"69";
	constant SSSIBitrateAddr : std_logic_vector(7 downto 0) := x"6A";
	constant	SSSIGlobalPStartAddr : std_logic_vector(7 downto 0) := x"6B";
	constant SSSINumRegs : std_logic_vector(7 downto 0) := x"04";
	constant SSSIMPBitMask : std_logic_vector(31 downto 0) := x"00000007";

	constant DPLLFreqLowAddr : std_logic_vector(7 downto 0) := x"70";  -- note overlaps translate RAM!
	constant DPLLFreqHighAddr : std_logic_vector(7 downto 0) := x"71"; -- will fix in the great re-alignment
	constant DPLLPostScaleAddr : std_logic_vector(7 downto 0) := x"72";
	constant DPLLIRateAddr : std_logic_vector(7 downto 0) := x"73";
	constant DPLLILimitAddr : std_logic_vector(7 downto 0) := x"74";
	constant DPLLPTweakAddr : std_logic_vector(7 downto 0) := x"75";
	constant DPLLITweakAddr : std_logic_vector(7 downto 0) := x"76";
	constant DPLLCountAddr : std_logic_vector(7 downto 0) := x"77";
	constant DPLLPhaseErrAddr : std_logic_vector(7 downto 0) := x"78";
	constant DPLLPostErrAddr : std_logic_vector(7 downto 0) := x"79";
	constant DPLLPostCountAddr : std_logic_vector(7 downto 0) := x"7A";	
	constant DPLLControlAddr : std_logic_vector(7 downto 0) := x"7B";
	constant DPLLNumRegs : std_logic_vector(7 downto 0) := x"0C";
	constant DPLLMPBitMask : std_logic_vector(31 downto 0) := x"000003FF";
	
	constant TranslateRamAddr : std_logic_vector(7 downto 0) := x"78";
	constant TranslateRegionAddr : std_logic_vector(7 downto 0) := x"7C";
	constant TranslateNumRegs : std_logic_vector(7 downto 0) := x"04";
	constant TranslateMPBitMask : std_logic_vector(31 downto 0) := x"00000000";

	constant ClockLow20: integer :=  33333333;  	-- 5I20/4I65 low speed clock
	constant ClockLow22: integer :=  48000000;	-- 5I22/5I23 low speed clock
	constant ClockLow23: integer :=  48000000;	-- 5I22/5I23 low speed clock
	constant ClockLow43: integer :=  50000000;	-- 7I43 low speed clock
	constant ClockLow43U: integer := 33333333;	-- 7I43U low speed clock
	constant ClockLow68: integer :=  48000000;	-- 4I68 low speed clock
	constant ClockLowx20: integer :=  50000000;	-- 3X20 low speed clock
	
	constant ClockHigh20: integer    := 100000000;	-- 5I20/4I65 high speed clock
	constant ClockHigh22: integer    := 96000000;	-- 5I22/5I23 high speed clock
	constant ClockHigh23: integer    := 96000000;	-- 5I22/5I23 high speed clock
	constant ClockHigh43: integer    := 100000000;	-- 7I43 high speed clock
	constant ClockHigh43U: integer   := 100000000;	-- 7I43U high speed clock
	constant ClockHigh68: integer    := 96000000;	-- 4I68 high speed clock
	constant ClockHighx20: integer   := 100000000;	-- 3X20 high speed clock
	
	constant ClockLowTag: std_logic_vector(7 downto 0) := x"01";

	constant ClockHighTag: std_logic_vector(7 downto 0) := x"02";
	
	constant NullTag : std_logic_vector(7 downto 0) := x"00";
		constant NullPin : std_logic_vector(7 downto 0) := x"00";
		
	constant IRQTag : std_logic_vector(7 downto 0) := x"01";

	constant WatchDogTag : std_logic_vector(7 downto 0) := x"02";

	constant IOPortTag : std_logic_vector(7 downto 0) := x"03";

	constant	QCountTag : std_logic_vector(7 downto 0) := x"04";
		constant QCountQAPin : std_logic_vector(7 downto 0) := x"01";
		constant QCountQBPin : std_logic_vector(7 downto 0) := x"02";
		constant QCountIdxPin : std_logic_vector(7 downto 0) := x"03";
		constant QCountIdxMaskPin : std_logic_vector(7 downto 0) := x"04";
		constant QCountProbePin : std_logic_vector(7 downto 0) := x"05";

	constant	StepGenTag : std_logic_vector(7 downto 0) := x"05";
		constant	StepGenStepPin : std_logic_vector(7 downto 0) := x"81";
		constant	StepGenDirPin : std_logic_vector(7 downto 0) := x"82";
		constant	StepGenTable2Pin : std_logic_vector(7 downto 0) := x"83";
		constant	StepGenTable3Pin : std_logic_vector(7 downto 0) := x"84";
		constant	StepGenTable4Pin : std_logic_vector(7 downto 0) := x"85";
		constant	StepGenTable5Pin : std_logic_vector(7 downto 0) := x"86";
		constant	StepGenTable6Pin : std_logic_vector(7 downto 0) := x"87";
		constant	StepGenTable7Pin : std_logic_vector(7 downto 0) := x"88";

	constant PWMTag : std_logic_vector(7 downto 0) := x"06";
		constant PWMAOutPin : std_logic_vector(7 downto 0) := x"81";
		constant PWMBDirPin : std_logic_vector(7 downto 0) := x"82";
		constant PWMCEnaPin : std_logic_vector(7 downto 0) := x"83";	

	constant SPITag : std_logic_vector(7 downto 0) := x"07";
		constant SPIFramePin : std_logic_vector(7 downto 0) := x"81";
		constant SPIOutPin : std_logic_vector(7 downto 0) := x"82";
		constant SPIClkPin : std_logic_vector(7 downto 0) := x"83";
		constant SPIInPin : std_logic_vector(7 downto 0) := x"04";
		
	constant SSSITag : std_logic_vector(7 downto 0) := x"08";
		constant SSSIClkPin : std_logic_vector(7 downto 0) := x"81";
		constant SSSIInPin : std_logic_vector(7 downto 0) := x"02";

	constant UARTTTag : std_logic_vector(7 downto 0) := x"09";
		constant UTDataPin : std_logic_vector(7 downto 0) := x"81";
		constant UTDrvEnPin : std_logic_vector(7 downto 0) := x"82";		

	constant UARTRTag : std_logic_vector(7 downto 0) := x"0A";
		constant URDataPin : std_logic_vector(7 downto 0) := x"01";	

	constant AddrXTag : std_logic_vector(7 downto 0) := x"0B";

	constant MuxedQCountTag: std_logic_vector(7 downto 0) := x"0C";
		constant MuxedQCountQAPin : std_logic_vector(7 downto 0) := x"01";
		constant MuxedQCountQBPin : std_logic_vector(7 downto 0) := x"02";
		constant MuxedQCountIdxPin : std_logic_vector(7 downto 0) := x"03";
		constant MuxedQCountIdxMaskPin : std_logic_vector(7 downto 0) := x"04";
		constant MuxedQCountProbePin : std_logic_vector(7 downto 0) := x"05";

	constant MuxedQCountSelTag: std_logic_vector(7 downto 0) := x"0D";
		constant MuxedQCountSel0Pin : std_logic_vector(7 downto 0) := x"81";
		constant MuxedQCountSel1Pin : std_logic_vector(7 downto 0) := x"82";

	constant BSPITag : std_logic_vector(7 downto 0) := x"0E";
		constant BSPIFramePin : std_logic_vector(7 downto 0) := x"81";
		constant BSPIOutPin : std_logic_vector(7 downto 0) := x"82";
		constant BSPIClkPin : std_logic_vector(7 downto 0) := x"83";
		constant BSPIInPin : std_logic_vector(7 downto 0) := x"04";
		constant BSPICS0Pin : std_logic_vector(7 downto 0) := x"85";
		constant BSPICS1Pin : std_logic_vector(7 downto 0) := x"86";
		constant BSPICS2Pin : std_logic_vector(7 downto 0) := x"87";
		constant BSPICS3Pin : std_logic_vector(7 downto 0) := x"88";
		constant BSPICS4Pin : std_logic_vector(7 downto 0) := x"89";
		constant BSPICS5Pin : std_logic_vector(7 downto 0) := x"8A";
		constant BSPICS6Pin : std_logic_vector(7 downto 0) := x"8B";
		constant BSPICS7Pin : std_logic_vector(7 downto 0) := x"8C";

	constant DBSPITag : std_logic_vector(7 downto 0) := x"0F";
		constant DBSPIOutPin : std_logic_vector(7 downto 0) := x"82";
		constant DBSPIClkPin : std_logic_vector(7 downto 0) := x"83";
		constant DBSPIInPin : std_logic_vector(7 downto 0) := x"04";
		constant DBSPICS0Pin : std_logic_vector(7 downto 0) := x"85";
		constant DBSPICS1Pin : std_logic_vector(7 downto 0) := x"86";
		constant DBSPICS2Pin : std_logic_vector(7 downto 0) := x"87";
		constant DBSPICS3Pin : std_logic_vector(7 downto 0) := x"88";
		constant DBSPICS4Pin : std_logic_vector(7 downto 0) := x"89";
		constant DBSPICS5Pin : std_logic_vector(7 downto 0) := x"8A";
		constant DBSPICS6Pin : std_logic_vector(7 downto 0) := x"8B";
		constant DBSPICS7Pin : std_logic_vector(7 downto 0) := x"8C";
		
	constant DPLLTag: std_logic_vector(7 downto 0) := x"10";
		constant DPLLSyncInPin : std_logic_vector(7 downto 0) := x"01";
		constant DPLLMSBOutPin : std_logic_vector(7 downto 0) := x"82";
		constant DPLLFOutPin : std_logic_vector(7 downto 0) := x"83";
		constant DPLLPostOutPin : std_logic_vector(7 downto 0) := x"84";
		constant DPLLSyncTogPin : std_logic_vector(7 downto 0) := x"85";
	

-- these are a muxed index mask varient of the muxed q counter
-- since they will never co-exist with the non muxed index mask varient
-- they share the same register decodes 
	constant MuxedQCountMIMTag: std_logic_vector(7 downto 0) := x"11";
		constant MuxedQCountMIMQAPin : std_logic_vector(7 downto 0) := x"01";
		constant MuxedQCountMIMQBPin : std_logic_vector(7 downto 0) := x"02";
		constant MuxedQCountMIMIdxPin : std_logic_vector(7 downto 0) := x"03";
		constant MuxedQCountMIMIdxMaskPin : std_logic_vector(7 downto 0) := x"04";

	constant MuxedQCountSelMIMTag: std_logic_vector(7 downto 0) := x"12";
		constant MuxedQCountSelMIM0Pin : std_logic_vector(7 downto 0) := x"81";
		constant MuxedQCountSelMIM1Pin : std_logic_vector(7 downto 0) := x"82";

	constant TPPWMTag : std_logic_vector(7 downto 0) := x"13";
		constant TPPWMAOutPin : std_logic_vector(7 downto 0) := x"81";
		constant TPPWMBOutPin : std_logic_vector(7 downto 0) := x"82";
		constant TPPWMCOutPin : std_logic_vector(7 downto 0) := x"83";	
		constant NTPPWMAOutPin : std_logic_vector(7 downto 0) := x"84";
		constant NTPPWMBOutPin : std_logic_vector(7 downto 0) := x"85";
		constant NTPPWMCOutPin : std_logic_vector(7 downto 0) := x"86";
		constant TPPWMEnaPin : std_logic_vector(7 downto 0) := x"87";
		constant TPPWMFaultPin : std_logic_vector(7 downto 0) := x"08";
		
	
	constant LEDTag : std_logic_vector(7 downto 0) := x"80";

	constant GlobalChan: std_logic_vector(7 downto 0) := x"80";	
	
	constant emptypin : std_logic_vector(31 downto 0) := x"00000000";
	constant empty : std_logic_vector(31 downto 0) := x"00000000";
	constant PadT : std_logic_vector(7 downto 0) := x"00";
	constant MaxModules : integer := 32;			-- maximum number of module types 
	constant MaxPins : integer := 144;				-- maximum number of I/O pins (may change to 144 with 3X20)

-- would be better to change all the pindescs to records
-- but that requires reversing the byte order of the constant
-- pindesc arrays, some other day...

	type PinDescRecord is  -- not used yet!
	record
		SecPin : std_logic_vector(7 downto 0);	
		SecFunc : std_logic_vector(7 downto 0);	
		SecInst : std_logic_vector(7 downto 0);	
		PriFunc : std_logic_vector(7 downto 0);	
	end record;
	
	type PinDescType is array(0 to MaxPins -1) of std_logic_vector(31 downto 0);
	
	type ModuleRecord is 
	record	
		GTag : std_logic_vector(7 downto 0);		
		Version : std_logic_vector(7 downto 0);	
		Clock : std_logic_vector(7 downto 0);
		NumInstances : std_logic_vector(7 downto 0);
		BaseAddr : std_logic_vector(15 downto 0);
		NumRegisters : std_logic_vector(7 downto 0);
		Strides : std_logic_vector(7 downto 0);
		MultRegs : std_logic_vector(31 downto 0);
	end record; 
	

	type ModuleIDType is array(0 to MaxModules-1) of ModuleRecord;


end package IDROMConst;

