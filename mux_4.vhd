-- Projeto de um MUX 4X1 entrada tamanho genérico
library ieee;
use ieee.std_logic_1164.all;

entity mux_4 is
	generic (
		Size : natural := 6
	);	
	port(
		A, B, C, D : in std_logic_vector(Size-1 downto 0);
		sel 		  : in std_logic_vector(1 downto 0);
		result 	  : out std_logic_vector(Size-1 downto 0)
	);
end entity;

architecture behaviour of mux_4 is
	
begin

	with sel select
		result <= A when "00",
					 B when "01",
					 C when "10",
					 D when others;					  
end behaviour;
