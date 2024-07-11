library ieee;
use ieee.std_logic_1164.all;

entity mux_2 is
	generic (
		Size : natural := 6
	);	
	port(
		A, B 	  : in std_logic_vector(Size-1 downto 0);
		sel 		  : in std_logic;
		result 	  : out std_logic_vector(Size-1 downto 0)
	);
end entity;

architecture behaviour of mux_2 is
	
	begin
	
		with sel select
			result <= A when '0',
						 B when others;
						  
end behaviour;
