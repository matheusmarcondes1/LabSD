-- Projeto de registrador tamanho genérico
-- com entrada reset e load síncronas

LIBRARY IEEE;
use ieee.std_logic_1164.all;

entity Reg_Generic is
	
	generic(
		DATA_WIDTH : natural := 4
	);
	port( 
	-- Inputs
		clock, reset, load : in std_logic;
		D						 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
	-- Outputs
		Q	: out std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0')
	    );
		 
end Reg_Generic;

architecture RTL of Reg_Generic is

begin
-- Reseta em nível lógico '1'
-- Carga em nível lógico '1'
	Q <= (others => '0') when reset = '1' else
	D when rising_edge(clock) and load='1';

end RTL;