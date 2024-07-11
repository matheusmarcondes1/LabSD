LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Incrementador is
	generic(
		DATA_WIDTH : natural := 4
	);
	port(
		A   		: in   	std_logic_vector(DATA_WIDTH-1 downto 0);
		result 	: out		std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end Incrementador;

architecture RTL of Incrementador is
		signal convert : unsigned(DATA_WIDTH-1 downto 0);	
begin
	convert <= unsigned(A);
	process(convert) is
		begin
				result <= std_logic_vector(convert + 1);
	end process;
end RTL;