library IEEE;
use IEEE.std_logic_1164.all;  -- defines std_logic types
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;


entity b32test is  
 
  port (
	LCLK : in std_logic;
	IOBITS: inout std_logic_vector (71 downto 0);			
   LEDS: out std_logic_vector(1 downto 0)

	);
end b32test;

architecture dataflow of b32test is

--	alias SYNCLK: std_logic is LCLK;

-- CLK multiplier DCM signals

signal fclk : std_logic;
signal clkfx: std_logic;
signal clk0: std_logic;

signal iabus: std_logic_vector(11 downto 0);
signal idbus: std_logic_vector(23 downto 0); 
signal mradd: std_logic_vector(11 downto 0);
signal mwadd: std_logic_vector(11 downto 0);
signal mibus: std_logic_vector(31 downto 0);   
signal mobus: std_logic_vector(31 downto 0);
signal mwrite: std_logic;      
signal mread: std_logic;	
			
signal testport: std_logic_vector(23 downto 0); 
signal muxedmibus: std_logic_vector(31 downto 0); 
signal ioradd: std_logic_vector(11 downto 0);

begin

   ClockMult : DCM
   generic map (
      CLKDV_DIVIDE => 2.0,
      CLKFX_DIVIDE => 2, 
      CLKFX_MULTIPLY => 4,			-- 3 for 72, 4 FOR 96 MHz, 5 for 120 MHz, 6 for 144 MHz
      CLKIN_DIVIDE_BY_2 => FALSE, 
      CLKIN_PERIOD => 20.0,          
      CLKOUT_PHASE_SHIFT => "NONE", 
      CLK_FEEDBACK => "1X",         
      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", 
                                            
      DFS_FREQUENCY_MODE => "LOW",
      DLL_FREQUENCY_MODE => "LOW",
      DUTY_CYCLE_CORRECTION => TRUE,
      FACTORY_JF => X"C080",
      PHASE_SHIFT => 0, 
      STARTUP_WAIT => FALSE)
   port map (
 
      CLK0 => clk0,   	-- 
      CLKFB => clk0,  	-- DCM clock feedback
		CLKFX => clkfx,
      CLKIN => LCLK,    -- Clock input (from IBUFG, BUFG or DCM)
      PSCLK => '0',   	-- Dynamic phase adjust clock input
      PSEN => '0',     	-- Dynamic phase adjust enable input
      PSINCDEC => '0', 	-- Dynamic phase adjust increment/decrement
      RST => '0'        -- DCM asynchronous reset input
   );
  
  BUFG_inst : BUFG
   port map (
      O => FClk,    -- Clock buffer output
      I => clkfx      -- Clock buffer input
   );

  -- End of DCM_inst instantiation

aproc: entity Big32

	port map (
		clk      => fclk,
		reset    => '0',
		iabus    => iabus,  		-- program address bus
		idbus    => idbus,      -- program data bus  
		mradd    => mradd,  		-- memory read address
		mwadd    => mwadd,  		-- memory write address
		mibus    => muxedmibus,  		-- memory data in bus     
		mobus    => mobus, 		-- memory data out bus
		mwrite   => mwrite,		-- memory write signal        
		mread		=> mread,      -- memory read signal 				
		carryflg => LEDS(0)		-- carry flag
		);

  programROM : entity testrom 
  port map(
		addr => iabus(10 downto 0),
		clk  => fclk,
		din  => x"000000",
		dout => idbus,
		we	=> '0'
	 );

  DataRam : entity testram 
  port map(
		addra => mwadd(10 downto 0),
		addrb => mradd(10 downto 0),
		clk  => fclk,
		dina  => mobus,
--		douta => 
		doutb => mibus,
		wea	=> mwrite
	 );


	testouts:  process(fclk)
	begin
		if rising_edge(fclk) then
			ioradd <= mradd;		
			if mwadd = x"000" and mwrite ='1' then
				testport <= mobus(23 downto 0);
			end if;
		end if;
		IOBITS(23 downto 0) <= testport;
		IOBITS(71 downto 48) <= (others => '0');
		
		
		
		if ioradd = x"001" then
			muxedmibus <= x"00" & IOBITS(47 downto 24);
		else
			muxedmibus <= mibus;
		end if;
		
		LEDS(1) <= '0';
		
		
	end process testouts;	

	
end dataflow;

  