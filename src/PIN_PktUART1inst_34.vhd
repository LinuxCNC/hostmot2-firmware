library IEEE;
use IEEE.std_logic_1164.all;  -- defines std_logic types
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Copyright (C) 2007, Peter C. Wallace, Mesa Electronics
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
--   * Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
-- 
--   * Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
-- 
--   * Neither the name of Mesa Electronics nor the names of its
--     contributors may be used to endorse or promote products
--     derived from this software without specific prior written
--     permission.
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

use work.IDROMConst.all;
-- We only need to edit colomn 4 which is the number of instances of each item. This must match the number of instances defined below in the pin defs

package PIN_PktUART1inst_34 is
	constant ModuleID : ModuleIDType :=( 
		(WatchDogTag,	x"00",	ClockLowTag,	    x"01",	WatchDogTimeAddr&PadT,		    WatchDogNumRegs,		x"00",	WatchDogMPBitMask),
		(IOPortTag,		x"00",	ClockLowTag,	    x"02",	PortAddr&PadT,					IOPortNumRegs,			x"00",	IOPortMPBitMask),
		(QcountTag,		x"02",	ClockLowTag,	    x"03",	QcounterAddr&PadT,			    QCounterNumRegs,		x"00",	QCounterMPBitMask),
		(StepGenTag,	x"02",	ClockLowTag,	    x"00",	StepGenRateAddr&PadT,		    StepGenNumRegs,		    x"00",	StepGenMPBitMask),
		(PWMTag,		x"00",	ClockHighTag,	    x"00",	PWMValAddr&PadT,				PWMNumRegs,				x"00",	PWMMPBitMask),
		(PktUARTTTag,	x"00",	ClockLowTag,	    x"01",	PktUARTTDataAddr&PadT,			PktUARTTNumRegs,		x"00",	PktUARTTMPBitMask),
		(PktUARTRTag,	x"00",	ClockLowTag,	    x"01",	PktUARTRDataAddr&PadT,			PktUARTRNumRegs,		x"00",	PktUARTRMPBitMask),
		(LEDTag,		x"00",	ClockLowTag,	    x"01",	LEDAddr&PadT,					LEDNumRegs,				x"00",	LEDMPBitMask),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,			x"00",	NullAddr&PadT,					x"00",					x"00",	x"00000000")
		);


	constant PinDesc : PinDescType :=(
-- 	Base func  sec unit sec func 	 sec pin					-- external DB25
		IOPortTag & x"00" & NullTag & NullPin,				    -- I/O 00	PIN 1	just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 01	PIN 14 	just GPIO  
		IOPortTag & x"00" & PktUARTTTag & PktUTDataPin,	        -- I/O 02	PIN 2   PktUART TX
		IOPortTag & x"00" & PktUARTRTag & PktURDataPin, 		-- I/O 03	PIN 15	PktUART RX
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 04	PIN 3	just GPIO   
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 05	PIN 16  just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 06	PIN 4	just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 07	PIN 17	just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 08	PIN 5 	just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 09	PIN 6	just GPIO
		IOPortTag & x"02" & QCountTag & QCountQAPin,			-- I/O 10	PIN 7	Encoder 2 (Quad A)
		IOPortTag & x"02" & QCountTag & QCountQBPin,			-- I/O 11	PIN 8	Encoder 2 (Quad B)
		IOPortTag & x"01" & QCountTag & QCountQAPin,  		    -- I/O 12	PIN 9	Encoder 1 (Quad A)
		IOPortTag & x"01" & QCountTag & QCountQBPin,			-- I/O 13	PIN 10	Encoder 1 (Quad B)
		IOPortTag & x"00" & QCountTag & QCountQBPin,  		    -- I/O 14	PIN 11	Encoder 0 (Quad A)
		IOPortTag & x"00" & QCountTag & QCountQAPin,  		    -- I/O 15	PIN 12	Encoder 0 (Quad B)
		IOPortTag & x"00" & QCountTag & QCountIdxPin,    	    -- I/O 16	PIN 13	Encoder 0 (Quad Idx)
		
																			-- 26 HDR	-- IDC DB25	
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 17	PIN 1		PIN 1 	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 18   PIN 2		PIN 14	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 19   PIN 3		PIN 2	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 20	PIN 4		PIN 15	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 21	PIN 5		PIN 3	   just GPIO   
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 22	PIN 6		PIN 16	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 23	PIN 7		PIN 4	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 24	PIN 8		PIN 17	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 25	PIN 9		PIN 5	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 26	PIN 11	    PIN 6	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,	 				-- I/O 27	PIN 13	    PIN 7	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 28	PIN 15	    PIN 8	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 29	PIN 17	    PIN 9	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,					-- I/O 30	PIN 19	    PIN 10	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,			  		-- I/O 31	PIN 21	    PIN 11     just GPIO
		IOPortTag & x"00" & NullTag & NullPin,			  		-- I/O 32	PIN 23	    PIN 12	   just GPIO
		IOPortTag & x"00" & NullTag & NullPin,			    	-- I/O 33	PIN 25	    PIN 13	   just GPIO
		

		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin, -- added for 34 pin 5I25
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,


		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin, -- added for IDROM v3
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
					
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin);

end package PIN_PktUART1inst_34;