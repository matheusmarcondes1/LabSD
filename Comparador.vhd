-- Comparador de magnitude tamanho genérico
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
	
entity Comparador is
	Generic(
		DATA_WIDTH : natural := 4
	);
	Port (
	-- Inputs
		A, B : in std_logic_vector(DATA_WIDTH - 1 downto 0);
		
	--Outputs
		MENOR, IGUAL, MAIOR : out std_logic
	);
end Comparador;

architecture RTL of comparador is	
	
begin	
	
	MAIOR <= '1' when (A>B) else '0';		
	MENOR <= '1' when (A<B) else '0';
	IGUAL <= '1' when (A=B) else '0';		
		
end RTL;