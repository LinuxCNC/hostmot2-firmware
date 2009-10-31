library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
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

entity SimpleSSI is
    Port ( clk : in std_logic;
	 		  ibus : in std_logic_vector(31 downto 0);
           obus : out std_logic_vector(31 downto 0);
           loadbitcount : in std_logic;
           loadbitrate : in std_logic;
			  lstart : in std_logic;
			  tstart : in std_logic;
			  pstart : in std_logic;
           readdata : in std_logic;
			  readbitcount : in std_logic;
           readbitrate : in std_logic;
			  busyout : out std_logic;
           ssiclk : out std_logic;
           ssiin : in std_logic
          );
end SimpleSSI;

architecture Behavioral of SimpleSSI is


signal BitrateDDSReg : std_logic_vector(15 downto 0);
signal BitrateDDSAccum : std_logic_vector(15 downto 0);
alias  DDSMSB : std_logic is BitrateDDSAccum(15);
signal OldDDSMSB: std_logic;  
signal BitcountReg : std_logic_vector(5 downto 0);
signal BitCount : std_logic_vector(5 downto 0);
signal SkewReg : std_logic_vector(3 downto 0);
signal SSISreg: std_logic_vector(31 downto 0);
signal SSILatch: std_logic_vector(31 downto 0);
signal Go: std_logic; 
signal Start: std_logic;
signal BitZero: std_logic; 
signal OldBitZero: std_logic;
signal PStartmask: std_logic; 
signal TStartmask: std_logic; 
signal MaskFirst: std_logic; 
signal SampleTime: std_logic; 
 
begin

	assiinterface: process (clk)
	begin
		if clk'event and clk = '1' then

			if Start = '1' then 
				BitCount <= BitCountReg;
				Go <= '1';
				SSISreg <= (Others => '0');
				MaskFirst <= '0';
				BitZero <= '0';
			end if;

			if Go = '1' then 
				BitRateDDSAccum <= BitRateDDSAccum + BitRateDDSReg;
			else
				BitRateDDSAccum <= (others => '0');
			end if;
			
			if SampleTime = '1' then
				if MaskFirst = '1' then 
					SSISreg <= SSISreg(30 downto 0) & ssiin;
				end if;
				if BitCount /= "000000" then
					BitCount <= BitCount -1;
					MaskFirst <= '1';		-- first clock just latches data so dont shift in
				end if;
				if BitCount = "000001" then
					BitZero <= '1'; 		-- at bit count of zero, (delayed count of 1);
				else
					BitZero <= '0';
				end if;
			end if;

			if BitZero = '0' and OldBitZero = '1' then
				Go <= '0';
				SSILatch <= SSISReg;
			end if;

			OldDDSMSB <= DDSMSB;
			OldBitZero <= BitZero;

			if loadbitcount =  '1' then 
				BitCountReg <= ibus(5 downto 0);
				PStartMask <= ibus(6);
				TStartMask <= ibus(7);
			end if;
			if loadbitrate =  '1' then 
				BitRateDDSReg <= ibus(15 downto 0);				 
			end if;	

		end if; -- clk

		if lstart = '1' or (tstart = '1' and TStartMask = '1') or (pstart = '1' and PStartMask = '1')then
			Start <= '1';
		else
			Start <= '0';
		end if;
		
		SampleTime <= OldDDSMSB and not DDSMSB;

		obus <= (others => 'Z');
      if readdata =  '1' then
			obus <= SSILatch;
		end if;
		if	readbitcount =  '1' then
			obus(5 downto 0) <= BitCountReg;
			obus(30 downto 8) <= (others => '0');
			obus(6) <= PStartMask;	
			obus(7) <= TStartMask;			
			obus(31) <= Go;
		end if;
      if readbitrate =  '1' then
			obus(15 downto 0) <= BitRateDDSReg;
			obus(31 downto 0) <= (others => '0');
		end if;
		ssiclk <= not DDSMSB; -- hold time is guaranteed by two directional propagation delay
		busyout <= Go;
	end process assiinterface;
	
end Behavioral;
