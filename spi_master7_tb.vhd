--********************************************************************************************************************--
--! @spi_master
--! @Configuring SPI Master as FPGA
--! Copyright2020 - Group Y
--********************************************************************************************************************--


library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity spi_master7_tb is
end;

architecture bench of spi_master7_tb is

  constant n_bit : integer := 18;  
  
  component spi_master7
  	port (
  		clk              : in std_logic;
  		reset            : in std_logic;
  		start            : in std_logic;
  		miso             : in std_logic;
  		sclk             : out std_logic;
  		cs               : out std_logic;
  		mosi             : out std_logic;
  		rx_data          : out std_logic_vector(11 downto 0));
  end component;

  signal clk: std_logic := '0';
  signal reset: std_logic;
  signal start: std_logic := '1';
  signal miso: std_logic  := '0';
  signal sclk: std_logic;
  signal cs: std_logic;
  signal mosi: std_logic;
  signal rx_data: std_logic_vector(11 downto 0);

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: spi_master7
							  port map 
							 ( clk     => clk,
                              reset   => reset,
                              start   => start,
                              miso    => miso,
                              sclk    => sclk,
                              cs      => cs,
                              mosi    => mosi,
                              rx_data => rx_data );

 
-- A stimulus process that toggles between start inputs
 -- stimulus: process
  -- begin
  
   -- start <= '1';
   -- wait for 3000 ns;
   -- start <= '0';
   -- reset <= '1';
   -- wait for 3000 ns;
   -- start <= '1';
   -- reset <= '0';
   -- wait for 8000 ns;
   -- start <= '1';
   -- reset <= '1';
   -- wait for 3000 ns;
   -- start <= '1';
   -- reset <= '0';
 
    -- wait;
  -- end process;


--Process that toggles clock
  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;
  
  
   -- Stimulus process that receives miso bits
   stim_proc: process
   begin		
   wait until falling_edge(cs); -- Wait until chip select low
   
   -- First four values are zero
   wait until falling_edge(sclk);   
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '0';
   
   -- 12 Bit ADC Value
   wait until falling_edge(sclk); -- Wait until falling edge according to the ADC timing diagram
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '1';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '1';
   wait until falling_edge(sclk);
   miso <= '1';
   wait until falling_edge(sclk);
   miso <= '1';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until falling_edge(sclk);
   miso <= '0';
   wait until rising_edge(cs);  -- Stops transaction when chip select is high
  
   -- An assert command that validates our results
   assert rx_data = "000010011100"
     report "Dead Wrong Mate!";
	 
   end process;
  
  
  -- A process that forces the start and reset input
   process(clk)
	begin
	if (rising_edge(clk)) then
		if(start = '0') then		
			start <= '1';
			reset <= '1';
		elsif(start = '1') then
			start <= '1';
			reset <= '1';		
		end if;
	end if;
	end process;
  

end;
  

  