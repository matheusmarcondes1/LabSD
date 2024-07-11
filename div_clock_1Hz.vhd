library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity div_clock_1Hz is
	port 
	(
		CLOCK_50MHz : in std_logic;
		CLOCK_1Hz   : out std_logic :='0'
	);

end entity;

architecture behaviour of div_clock_1Hz is

	constant Divisor : integer := 25000000;
	
begin

	process (CLOCK_50MHz)
		variable cnt : integer range 0 to Divisor;
		variable clk : std_logic:='0';
	begin

		if (rising_edge(CLOCK_50MHz)) then
		   if (cnt = Divisor) then
			   clk := not clk;
				cnt := 0;
			else
		      cnt := cnt + 1;	
			end if;
		end if;
		CLOCK_1Hz <= clk;
	end process;

end behaviour;