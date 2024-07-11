-- Projeto de Comparador igual a zero
library ieee;
use ieee.std_logic_1164.all;

entity Comparador_Eq_0 is
	
	Generic (
		DATA_WIDTH : natural := 8
	);
	Port (
	-- Inputs
		A		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	-- Outputs
		A_Eq_0 : out std_logic
	);
end Comparador_Eq_0;

architecture RTL of Comparador_Eq_0 is

	signal B : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	process(A)
		begin
		if(A = B) then
			A_eq_0 <= '1';
		else
			A_eq_0 <= '0';
		end if;
	end process;
	
end RTL;