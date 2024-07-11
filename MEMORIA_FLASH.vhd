-- Projeto de registrador tamanho genérico
-- com entrada reset e load síncronas

LIBRARY IEEE;
use ieee.std_logic_1164.all;

entity MEMORIA_FLASH is
	port( 
		ADDR_FLASH	: in std_logic_vector (3 downto 0);
		DATA_FLASH	: out std_logic_vector (31 downto 0)
	    ); 
end MEMORIA_FLASH;

architecture RTL of MEMORIA_FLASH is

begin
	with ADDR_FLASH select
		DATA_FLASH <=  "01010101000101001111001000001010" when "0000",
					      "01110110000111010100001010001111" when "0001",
					      "10001010001001011001001100010100" when "0010",
					      "00111000000111000000001010001010" when "0011",
					      "00000000000000000000000000000000" when OTHERS;
end RTL;

--RAPIDO - LV=10, ML=15, EN=10, CE=5, NE=NM=1, NUM_ETAPAS=5
--NORMAL - LV=15, ML=20, EN=15, CE=7, NE=1 e NM=2, NUM_ETAPAS=5
--INTENSA - LV=20, ML=25, EN=20, CE=9, NE=2 e NM=2, NUM_ETAPAS=5
--ENX+CENT- LV=10, ML=0, EN=10, CE=7, NE=2 e NM=0, NUM_ETAPAS=5