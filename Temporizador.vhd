library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Temporizador is
    Port (
        clk, reset, load    : in std_logic;
        entrada             : in std_logic_vector(5 downto 0);
        saida               : out std_logic := '0';
        timer               : out std_logic_vector(5 downto 0)
    );
end entity Temporizador;

architecture RTL of Temporizador is
    signal contador1 : integer range 0 to 50000000 := 0;
    signal decrementa : integer range 0 to 500 := 0;
	 signal carga : std_logic := '0';	 
begin   
	 process(clk, reset, load)
    begin
        if reset = '1' then
            contador1 <= 0;
            saida <= '0';
        elsif rising_edge(clk) and load = '1' then
            if contador1 < (to_integer(unsigned(entrada))) then
                contador1 <= contador1 + 1;
            else
                saida <= '1';
            end if;
        end if;
    end process; 
	 
	process(clk, reset, load)
	begin
		if reset = '1' then
			carga <= '0';
			timer <= (others => '0');
		elsif (load = '1') then
			if (carga = '0') then
				decrementa <= to_integer(unsigned(entrada));
				timer <= std_logic_vector(to_unsigned(decrementa, timer'length));
				carga <= '1';
			else
				if (rising_edge(clk)) then
					if(decrementa > 0) then 
						decrementa <= decrementa - 1;
					end if;
					timer <= std_logic_vector(to_unsigned(decrementa, timer'length));
				end if;
			end if;
		end if;
	end process;	
end RTL;


