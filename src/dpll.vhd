library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
--
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

entity dpll is
	port (
		clk     			: in  std_logic;
		ibus    			: in  std_logic_vector (31 downto 0);
		obus    			: out std_logic_vector (31 downto 0);
		loadfreqlow	   : in  std_logic;
		loadfreqhigh	: in  std_logic; 
		loadpostscale	: in  std_logic;
		loadirate	   : in  std_logic; 
		loadcontrol	   : in  std_logic;
		loaditweak	   : in  std_logic;
      loadptweak     : in  std_logic;
		loadilimit	   : in  std_logic;
		readirate	   : in  std_logic;
		readcount	   : in  std_logic;
		readcontrol	   : in  std_logic;
		readphaseerr	: in  std_logic;
		readposterr	   : in  std_logic;
		readpostcount	: in  std_logic;

	   sync	   		: in  std_logic;
		msbout  			: out std_logic;
		fout  			: out std_logic;
		postout			: out std_logic;
		synctog			: out std_logic
		
    );
end dpll;

architecture behavioral of dpll is

  signal count     : std_logic_vector (47 downto 0);
  alias msb : std_logic is count(47);
  signal msbd : std_logic;
  signal msbdd : std_logic;
  signal refout : std_logic;
  signal postscaleout : std_logic;
  signal psotimer  : std_logic_vector (7 downto 0);
  signal latch     : std_logic_vector (47 downto 0);
  signal phaserr   : std_logic_vector (31 downto 0);
  signal prate      : std_logic_vector (31 downto 0);
  signal irate      : std_logic_vector (31 downto 0);
  signal itweak     : std_logic_vector (31 downto 0);
  signal ptweak    : std_logic_vector (31 downto 0); 
  signal ilimit     : std_logic_vector (31 downto 0);
  signal postcount : std_logic_vector (15 downto 0);
  signal postscale : std_logic_vector (15 downto 0);
  signal posterr : std_logic_vector (15 downto 0);
  signal syncd		 : std_logic_vector(1 downto 0);
  signal controlreg : std_logic_vector(5 downto 0);
  signal syncfcount : std_logic_vector(3 downto 0);
  signal syncf : std_logic;
  alias synctoggle  : std_logic is controlreg(5);
  alias lowsync  : std_logic is controlreg(4);
  alias forcelock : std_logic is controlreg(3);
  alias accsync : std_logic is controlreg(2);
  alias postsync : std_logic is controlreg(1);  
  alias freerun : std_logic is controlreg(0);
 

begin

  adpll : process (clk,controlreg,refout,readirate, itweak, ptweak, 
                   readcount, count, readcontrol, readphaseerr, 
                   phaserr, readposterr, posterr, readpostcount, 
						 postcount, msbdd, postscaleout)

  begin
    if clk'event and clk = '1' then 	-- per clk stuff
		
		if (sync xor lowsync) = '1' then	-- deadended countter digital filter for sync 
			if syncfcount = x"F" then		-- adds 16 clocks to phase delay
				syncf <= '1';
			else
				syncfcount <= syncfcount +1;
			end if;
		else
			if syncfcount = x"0" then
				syncf <= '0';
			else
				syncfcount <= syncfcount -1;
			end if;
		end if;
		
      syncd <= syncd(0) & syncf;			-- left shift
      msbdd <= msbd;
		msbd <= msb;
 
      if msbd = '1' and msb = '0' then -- DDS MSB falling edge          
			refout <= '1';
			if postcount < postscale then
				postcount <= postcount +1;
			else
				postcount <= x"0000";
			   psotimer <= x"7F";
			end if;	
      else
        refout <= '0';
      end if;
		
		if psotimer(7) = '0' then 
			psotimer <= psotimer -1;
		   postscaleout <= '1';
		else
		   postscaleout <= '0';
		end if;
		
		
      count <= count + latch + irate + prate;


		if loadfreqlow = '1' then
			latch(31 downto 0)  <= ibus;
		end if;

		if loadfreqhigh = '1' then
			latch(47 downto 32)  <= ibus(15 downto 0);
		end if;

		if loadirate = '1' then
			irate <= ibus;
      end if;

		if loaditweak = '1' then 
			itweak <= ibus;
		end if;

		if loadptweak = '1' then 
			ptweak <= ibus;
		end if;

		if loadilimit = '1' then 
			ilimit <= ibus;
		end if;

		if loadpostscale = '1' then 
			postscale <= ibus(15 downto 0);
		end if;
		
		if loadcontrol = '1' then
			controlreg(4 downto 0) <= ibus(4 downto 0);
      end if;  
		
      -- Simple non-proportional (limited slew rate) DPLL

		if syncd = "01" and freerun = '0' then  -- sync rising edge 
			synctoggle <= not synctoggle;
			phaserr   <= count(47 downto 16);
			posterr <= postcount;
			if forcelock = '1' then
				count <= x"000000000000";
				postcount <= x"0000";
				msbd <= '0';							-- clear our edge detector so
															-- clearing count does not increment postcount
			end if;
		  	-- phase detector:
			if ((postcount > ('0'& postscale(15 downto 1)) and postsync = '1')) -- less than halfway up
			or (msbdd = '1' and accsync = '1') then  -- if accumulator has not wrapped then frequency is low
				if irate < ilimit then
					irate <= irate + itweak;
				end if;	
				prate <= ptweak;
			else
				if irate > -ilimit then
					irate <= irate - itweak;  -- otherwise frequency is high -- slow down
				end if;
				prate <= -ptweak;
			end if;
      end if; -- sync rising edge;
		
		
    end if;  -- clk      

	obus <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
--	if readfreqlow = '1' then
--		obus <= latch(31 downto 0);
--	end if;

--	if readfreqhigh = '1' then
--		obus(15 downto 0) <= latch(47 downto 32);
--		obus(31 downto 16) <= (others => '0');
--	end if;

	if readirate = '1' then
		obus <= irate;
	end if;

--	if readlimit = '1' then 
--		obus <= limit;
--	end if;

--	if readpostscale = '1' then 
--		obus(15 downto 0) <= postscale;
--		obus(31 downto 16) <= (others => '0');
--	end if;

--	if readtweak = '1' then 
--		obus <= tweak;
--	end if;

	if readcount = '1' then 
		obus <= count(47 downto 16);
	end if;
	
	if readcontrol = '1' then
		obus(5 downto 0) <= controlreg;
		obus(31 downto 6) <= (others => '0');
	end if;  
		
	if readphaseerr = '1' then
		obus <= phaserr;
	end if;

	if readposterr = '1' then
		obus(15 downto 0) <= posterr;
		obus(31 downto 16) <= (others => '0');		
	end if;

	if readpostcount = '1' then
		obus(15 downto 0) <= postcount;
		obus(30 downto 16) <= (others => '0');
		obus(31) <= synctoggle;
	end if;
										-- debug outputs
	fout <= refout;				-- binary phase accumulator 1 clock width out
   msbout <= msbdd; 				-- binary phase accumulator 50 
	postout <= postscaleout;	-- postscaler clock out ~ 128 clocks
	synctog <= synctoggle;		-- toggles on input sync
  end process;
end behavioral;
