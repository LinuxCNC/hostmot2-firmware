library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;
--
-- Copyright (C) 2009, Peter C. Wallace, Mesa Electronics
-- Copyright (C) 2020, Curtis E Dutton, Dutton Industrial
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


--The Sigma5Enc component transmits
--manchester encoded data then listens for a response from a Sigma V encoders
entity Sigma5Enc is
    generic (
        buswidth : integer
        );
    Port (  
        clkmed : in std_logic;
        clklow : in std_logic;
        ibus : in std_logic_vector(buswidth-1 downto 0);   --host bus data in
        obus : out std_logic_vector(buswidth-1 downto 0);  --host bus data outa
        timers : in std_logic_vector(4 downto 0); --dpll timers
        bus_load_control : in std_logic;  --load transmit from control register
        bus_store_rx0 : in std_logic;
        bus_store_rx1 : in std_logic;
        bus_store_rx2 : in std_logic;
        bus_store_status : in std_logic;
        txdata : out std_logic; --transmit data
        txen : out std_logic; --transmit enable
        rxdata : in std_logic  --receive data
        
    );
end Sigma5Enc;

architecture Behavioral of Sigma5Enc is

    constant bitrate : std_logic_vector(7 downto 0) := x"0C"; --100MHZ / 12 = 8333333 MHZ

    signal enable : std_logic; --when true transmit cycle is enabled
    signal transmitting : std_logic;  --controls transmit recieve cycle
    signal transmit : std_logic; --start a transmit cycle
    signal transmit_prev : std_logic;

    signal rx_ok : std_logic;
    signal busy : std_logic;
    signal any_data_received : std_logic;

    --rx manchester decoding process variables
    signal rx_manchester_input : std_logic;
    signal rx_manchester_input_prev : std_logic;
    signal rx_manchester_timer : std_logic_vector(31 downto 0);
    signal rx_manchester_recovery_clk : std_logic;
    signal rx_manchester_bit : std_logic;
    signal rx_manchester_clk : std_logic;


    --hdlc decoding process variables
    type hdlc_states is (hdlc_idle, hdlc_starting, hdlc_running, hdlc_complete, hdlc_error);
    signal hdlc_state : hdlc_states;
    signal hdlc_unstuff_counter : std_logic_vector(2 downto 0);
    signal hdlc_buffer : std_logic_vector(7 downto 0);
    signal hdlc_clk : std_logic;
    signal hdlc_bit : std_logic;


    signal crc : std_logic_vector(15 downto 0);
    signal crc_count : std_logic_vector(7 downto 0);
 
    

    --number of bits receive
    signal rx_count : std_logic_vector(7 downto 0);
    signal rx_register : std_logic_vector(111 downto 0);


    signal tx_data : std_logic_vector(39 downto 0);
    signal tx_count : std_logic_vector(5 downto 0); --number of bits to transmit
    signal tx_en_counter : std_logic_vector(7 downto 0); --used to time enable signal setup
    signal tx_interval_counter : std_logic_vector(7 downto 0); --counts from N to 0. Used to control bit rate output
    signal tx_manchester_clk : std_logic; --tracks manchester bit status to convert to manchester coding

    signal timer_enable : std_logic;
    signal timer_sel : std_logic_vector(2 downto 0);
    signal timer : std_logic;
    signal timer_prev : std_logic;


    --(val >> 1)
    function one_half(val : in std_logic_vector(7 downto 0))
        return std_logic_vector is
    begin
        return ('0' & val(7 downto 1));
    end function;

    --(val >> 1) + val
    function three_half(val : in std_logic_vector(7 downto 0))
        return std_logic_vector is
    begin
        return ('0' & val(7 downto 1)) + val;
    end function;

    --(val >> 1) + (val << 1)
    function five_half(val : in std_logic_vector(7 downto 0))
        return std_logic_vector is
    begin
        return ('0' & val(7 downto 1)) + (val(6 downto 0) & '0');
    end function;



begin
    mantrx : process(clkmed)                             
    begin
    
    if rising_edge(clkmed)
    then
        timer_prev <= timer;
        transmit_prev <= transmit;

        case timer_sel is
            when "000" => timer <= timers(0);
            when "001" => timer <= timers(1);
            when "010" => timer <= timers(2);
            when "011" => timer <= timers(3);
            when "100" => timer <= timers(4);
            when others => timer <= timers(0);
        end case;

   end if;
    end process;

--decodes manchester encoded serial data from input
rx_manchester : process(clkmed)
begin 
    if rising_edge(clkmed) then
        rx_manchester_input_prev <= rxdata;
        rx_manchester_input <= rx_manchester_input_prev;

        if transmitting = '1' then
            --reset receive data
            rx_manchester_timer <= (others=>'0');
            rx_manchester_recovery_clk <= '0';
            rx_manchester_clk <= '0';
            rx_manchester_bit <= '0';
            busy <= '1';
        else
            if rx_manchester_input /= rx_manchester_input_prev then
                rx_manchester_timer <= (others=>'0');
   
                if rx_manchester_timer > one_half(bitrate) then
                    if rx_manchester_timer < three_half(bitrate) then
                        rx_manchester_recovery_clk <= not rx_manchester_recovery_clk;

                        if rx_manchester_recovery_clk = '1' then
                            rx_manchester_clk <= '1';
                            rx_manchester_bit <= rx_manchester_input;
                        else
                            rx_manchester_clk <= '0';
                        end if;
                    elsif rx_manchester_timer < five_half(bitrate) then
                            rx_manchester_recovery_clk <= '1';
                            rx_manchester_clk <= '1';
                            rx_manchester_bit <= rx_manchester_input;
                    else
                        rx_manchester_clk <= '0';
                    end if;
                end if;

            elsif rx_manchester_timer < five_half(bitrate) then
                rx_manchester_timer <= rx_manchester_timer + 1;
                rx_manchester_clk <= '0';
            elsif rx_manchester_timer = five_half(bitrate) then
                --after no more data comes in tack on an additionl 0 bit
                rx_manchester_clk <= '1';
                rx_manchester_bit <= '0';
                rx_manchester_timer <= rx_manchester_timer + 1;
                busy <= '0';
            else
                rx_manchester_clk <= '0';
            end if;
        end if; 
    end if;
end process;

--decodes an hdlc message from manchester decoded data
rx_decode_hdlc : process(clkmed)
    variable hdlc_next_bit : std_logic;
begin
    if rising_edge(clkmed) then
        if transmitting = '1' then
            hdlc_state <= hdlc_idle;
            hdlc_clk <= '0';
            hdlc_bit <= '0';
            hdlc_unstuff_counter <= (others=>'0');
            hdlc_buffer <= (others=>'0');
            any_data_received <= '0';
        else
            if rx_manchester_clk = '0' then
                hdlc_clk <= '0';
            else
                any_data_received <= '1';
                hdlc_next_bit := hdlc_buffer(hdlc_buffer'LEFT);

                if hdlc_state = hdlc_idle and hdlc_buffer = "01111110" then

                    hdlc_state <= hdlc_starting;
                    --the single bit acts as a sentinel
                    --this allows us to determine the buffer is full
                    hdlc_buffer <= "0000001" & rx_manchester_bit;
                else
                    hdlc_buffer <= hdlc_buffer(hdlc_buffer'LEFT-1 downto 0) & rx_manchester_bit;

                    if hdlc_state = hdlc_starting and hdlc_next_bit = '1' then
                        hdlc_state <= hdlc_running;

                    elsif hdlc_state = hdlc_running then

                        if hdlc_buffer = "01111110" then
                            hdlc_state <= hdlc_complete;
                        elsif hdlc_next_bit = '0' then
                            hdlc_unstuff_counter <= (others=>'0');
                            
                            if hdlc_unstuff_counter < 5 then
                                hdlc_clk <= '1';
                                hdlc_bit <= '0';

                            elsif hdlc_unstuff_counter > 5 then
                                hdlc_state <= hdlc_error;
                            end if;
                        else
                            hdlc_clk <= '1';
                            hdlc_bit <= '1';
                            hdlc_unstuff_counter <= hdlc_unstuff_counter + 1;  
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;


--copies hdlc decoded data into rx_register
rx_decode : process(clkmed)
begin
    if rising_edge(clkmed) then
        if transmitting = '1' then
            rx_register <= (others => '0');
            rx_count <= (others => '0');
        end if;

        if hdlc_clk = '1' then
            rx_register <= rx_register(rx_register'LEFT-1 downto 0) & hdlc_bit;
            rx_count <= rx_count + 1;
        end if;


        if crc = rx_register(15 downto 0) then
            rx_ok <= '1';
        else
            rx_ok <= '0';
        end if;

    end if;
end process;

--calculates crc value of the first 12 bytes of incoming hdlc decoded data
rx_crc : process(clkmed)
begin
    if rising_edge(clkmed) then
        if transmitting = '1' then
            crc <= x"FFFF";
            crc_count <= (others => '0');
        elsif hdlc_clk = '1' then

            if crc_count < 96 then
                crc(0)  <= hdlc_bit xor crc(15);
                crc(1)  <= crc(0);
                crc(2)  <= crc(1);
                crc(3)  <= crc(2);
                crc(4)  <= crc(3);
                crc(5)  <= hdlc_bit xor crc(4) xor crc(15);
                crc(6)  <= crc(5);
                crc(7)  <= crc(6);
                crc(8)  <= crc(7);
                crc(9)  <= crc(8);
                crc(10) <= crc(9);
                crc(11) <= crc(10);
                crc(12) <= hdlc_bit xor crc(11) xor crc(15);
                crc(13) <= crc(12);
                crc(14) <= crc(13);
                crc(15) <= crc(14);

                crc_count <= crc_count + 1;

            elsif crc_count = 96 then
                crc <= crc xor x"FFFF";
                crc_count <= crc_count + 1;
            end if;
        end if;
    end if;
end process;
                
                

--transmits manchester encoded data over tx
tx_manchester : process(clkmed)
begin 
    if rising_edge(clkmed) then
        if enable = '1' and
           ((transmit /= transmit_prev) or
           (timer_enable = '1' and timer_prev = '0' and timer = '1')) then
            transmitting <= '1';        
        end if;
 
        if transmitting  = '0' then
            --during recieve we can prepare for a tx
            tx_en_counter <= (others=>'0');
            tx_interval_counter <= (others=>'0');
            tx_manchester_clk <= '1';
            tx_data <= x"abf7df7d7e"; --hdlc encoded value of FFFF
            tx_count <= "101000"; --40 bits to transmit
            txen <= '0';
        else
            --assert txenable
            txen <= '1'; 
           
            --transmits data in tx_data register
            --trasnmits from MSB to LSB
            --converts to manchester code
            --mapping is 0 -> 01
            --           1 -> 10
            if tx_count /= 0 then
                if tx_en_counter < bitrate then
                    --make sure that txen is asserted
                    --prior to sending data
                    tx_en_counter <= tx_en_counter + 1;
                else
                    if tx_interval_counter /= 0 then
                        tx_interval_counter <= tx_interval_counter - 1;
                    else
                        if tx_manchester_clk = '1' then
                            txdata <= tx_data(tx_data'LEFT);
                        else
                            txdata <= not tx_data(tx_data'LEFT);
                            tx_data <= tx_data(tx_data'LEFT-1 downto 0) & '0';
                            tx_count <= tx_count - 1;
                        end if;
                        
                        tx_manchester_clk <= not tx_manchester_clk;
                        tx_interval_counter <= bitrate;
                    end if;
                end if;
            else
                if tx_en_counter /= 0 then
                    --make sure txen is asserted for one bitperiod 
                    --after data is sent
                    tx_en_counter <= tx_en_counter - 1;
                else
                    transmitting <= '0';
                end if;
            end if;
        end if;
    end if;
end process; 

load : process(clklow)
    begin
        if rising_edge(clklow) then
            if bus_load_control = '1' then
                enable <= ibus(0);
                transmit <= ibus(1);
                timer_enable <= ibus(2);
                timer_sel <= ibus(10 downto 8);
           end if;
        end if;
end process;


store : process(clklow)

    begin
        if falling_edge(clklow) then
            obus<= (others=>'Z');
            
            if bus_store_rx0 = '1' then
                obus <= rx_register(rx_register'LEFT downto rx_register'LEFT-31);
            end if;

            if bus_store_rx1 = '1' then
                obus <= rx_register(rx_register'LEFT-32 downto rx_register'LEFT-63);
            end if;

            if bus_store_rx2 = '1' then
                obus <= rx_register(rx_register'LEFT-64 downto rx_register'LEFT-95);
            end if;

            if bus_store_status = '1' then
                obus <= (0=>enable,
                         1=>transmit,
                         2=>timer_enable,
                         3=>rx_ok,
                         4=>busy,
                         5=>any_data_received,
                         others =>'0');

                obus(10 downto 8) <= timer_sel;

                obus(31 downto 16) <= crc;
            end if;
        end if;
    end process;
end Behavioral;
