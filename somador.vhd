library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador is

	Generic (
		DATA_WIDTH : natural := 8
	);
	Port 
	(
		a, b	   : in std_logic_vector	((DATA_WIDTH-1) downto 0);
		result   : out std_logic_vector 	((DATA_WIDTH-1) downto 0)
	);

end entity;

architecture soma of somador is
begin

	result <= std_logic_vector(unsigned(a) + unsigned(b));

end soma;
