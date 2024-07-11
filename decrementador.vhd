LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
entity decrementador is
	port(
		A   		: in   	std_logic_vector(1 downto 0);
		result 	: out		std_logic_vector(1 downto 0)
	);
end decrementador;

architecture decrementar of decrementador is
	begin
	process(A) is
		begin
			if A = "00" then
				result <= "00";
			else 
				result <= std_logic_vector(unsigned(A)-"01");
			end if;
	end process;

end decrementar;