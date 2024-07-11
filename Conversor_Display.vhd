-- Projeto para um conversor numero binario 6 bits
-- para multiplos displays (2 displays no total)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Conversor_Display is
    Port (
        tempo : in std_logic_vector(5 downto 0);
		  -- Saída para os displays de 7 segmentos
        display_1 : out std_logic_vector(3 downto 0);  --unidades
		  display_2 : out std_logic_vector(3 downto 0)   --dezenas
    );
end Conversor_Display;

architecture RTL of Conversor_Display is
	
	constant Maior 	: integer :=100;
	constant Menor 	: integer :=10;
   signal aux 			: integer :=0;
	signal total 			: integer :=0;
	signal dezenas			: integer :=0;
	signal unidades 		: integer :=0;
	
begin
	
	total <= to_integer(unsigned(tempo));
	display_1 <= std_logic_vector(to_unsigned(unidades, 4));
	display_2 <= std_logic_vector(to_unsigned(dezenas, 4));	
	aux 		 <= total mod Maior;
	dezenas   <= aux/Menor;
	unidades  <= aux mod Menor; 
	
end RTL;