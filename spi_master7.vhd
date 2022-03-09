--********************************************************************************************************************--
--! @spi_master
--! @Configuring SPI Master as FPGA
--! Copyright2020 - Group Y
--********************************************************************************************************************--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Local libraries
library work;

entity spi_master7 is
	

	port (
	    --Input ports
		clk              : in std_logic;          -- System Clock
		reset            : in std_logic;          -- Asynchronous Reset
		start            : in std_logic;          -- Start transaction
		miso             : in std_logic;          -- Master In Slave Out
		
		--Output ports
		sclk             : out std_logic;         -- SPI Clock
		cs               : out std_logic;         -- Chip select
		mosi             : out std_logic;	      -- Master Out Slave In  (MOSI)
		rx_data          : out std_logic_vector(11 downto 0));	-- Data recieved on the output
		
		

end spi_master7;


architecture spi_brain of spi_master7 is

  constant n_bit  : integer := 18;     -- Data length in bits in addition with delay
  type state_type is (idle, run);      --State machine for when idle and to run
  type run_state is (miso_run);        -- Inside the run state. During miso transaction
  
--Assign signals
  signal miso_state : run_state;      -- A state for miso transaction
  signal state      : state_type;          --Current state

  signal cs_n                     : std_logic;  --Internal signal for cs
  signal mosi_n                   : std_logic;  --Internal signal for mosi
  signal count_data               : integer range 0 to n_bit-1;               --An integer that counts to 16
  signal rx_buffer                : std_logic_vector(11 downto 0):= (others => '0'); --Receive data buffer
  
  signal clk_scaler               : integer := 50;      -- Our clock runs at 50 MHz. This is to scale Sclk
  signal scale_cnt                : integer range 0 to 100 := 0;  -- A range that tells us if desirted value is reached
  signal s_sclk                   : std_logic := '0';        -- Start SPI clock at 0

begin

  -- Assign internal signals to ports
  cs    <= cs_n;  
  mosi  <= mosi_n;
  
 -- Clock scaling for SPI clock. Set to 1 MHz from 50 MHz system clock
	spi_clock_proc : process(clk)
	begin
		if rising_edge(clk) then
			if scale_cnt = clk_scaler -1  then     -- Checks if scale count is at wanted range. Keep decrementing
				s_sclk <= not(s_sclk);             -- Togggles SPI clk
				sclk <= (s_sclk);                 -- Toggle sclk signal
				scale_cnt <= 0;                    -- Count down from 50 to 0
			elsif (reset = '0') then
			    sclk  <= '1';                    -- Set Sclk to high when idle
				s_sclk <= '1';	
			else
				scale_cnt <= scale_cnt + 1;        -- Else increase range
				sclk <=(s_sclk);                  -- Toggle sclk signal	
			end if;
		end if;
	end process spi_clock_proc;

	
  -- The process to receive data from the ADC test bench using the SPI clock
    data_transaction : process(s_sclk, reset)
    begin  

	
	 if (reset = '0') then         -- If reset is off, then idle
	   cs_n          <= '1';       -- Set slaves high (off)
	   mosi_n        <= '0';             -- Set mosi to 0
	   rx_data       <= (others => '0'); -- Set receive data port to 0
	   state         <= idle;           -- idle signal when reset done
	   
	 elsif rising_edge(s_sclk) then
	  if (start = '1') then           -- Start transaction if start is high
	   state <= run;
	   case state is                   -- State type
	    when idle =>                   -- When idle
				mosi_n <= '0';         -- mosi to 0
				cs_n   <= '1';         -- Pull chip select high
				count_data <= 0;       -- Reset counter
				rx_data       <= (others => '0'); -- Set receive data to 0			
			when run =>
				cs_n <= '0';	
				mosi_n <= '0';	
				case miso_state is           -- Miso case statement
				when miso_run =>
					mosi_n <= '0';             -- Set mosi to 0
					if (cs_n = '0') then     -- Wait until chip select goes low
						rx_buffer <= rx_buffer(11-1 downto 0) & miso;  -- Store miso data into buffer and shift it
					end if;
					
					if (count_data = n_bit-1) then     -- Wait until 16 Sclk cycles
					    cs_n  <= '1';                  -- Pull chip select high  
						count_data <= 0;               -- Reset counter
						rx_data <= rx_buffer;          -- Transfer the data from the buffer to reciever port
						state <= idle;                 -- State now idle
	
					else
						state <= run;                  -- Keep running until 16 Sclk cycles
						count_data <= count_data + 1;  -- Increment counter
						
					end if;						
				end case;
			end case;
			
	  else
	    cs_n <= '1';    -- Pull chip select high if start is 0
		mosi_n <= '0';  -- Set mosi to 0
	  end if;
	  
	 
	 end if;
		
	end process data_transaction;
	
end spi_brain;	 
			 