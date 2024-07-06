--trabalho final dig-elt029 ufmg
--rtl design: implementação de um sistema de controle de lavadora automatica de roupas
--autoria: breno augusto e gabriel groppo @ escola de engenharia ufmg
-- CPU.vhd


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CPU is
	port (
	clk_50Mhz 					: in std_logic;					-- divisor de clock
	S, clear, ME, EE, SN 				: in std_logic;					-- 1 bit: S = start, ME = molho extra, EE = enxague extra, SN = sensor de nivel d'agua
	P, N, PS 					: in std_logic_vector(1 downto 0);		-- 2 bits: P = programa, N = nivel d'agua (selecionado pelo usuario), PS = presostato (peso do tanque)
	AF, BD 						: out std_logic;				-- 1 bit: AF = atuador do freio, BD = bomba de drenagem
	MOTOR 						: out std_logic_vector(3 downto 0);		-- 4 bits: MOTOR (forte/fraco/horario/antihorario)
	VALV_AGUA 					: out std_logic_vector(1 downto 0);		-- 2 bits: 
	D0, D1, D2, D3, D4, D5, D6, D7 			: out std_logic_vector(6 downto 0)		-- 7 bits: 8 displays (D0-D7) de 7-segmentos
	);
end entity;

architecture RTL of CPU is

	component Datapath is
		port(
			clk, ME, EE			: in std_logic;
			P, N, PS			: in std_logic_vector(1 downto 0);
			DATA_FLASH			: in std_logic_vector(31 downto 0);
			load_selection			: in std_logic;
			load_config			: in std_logic;
			load_NM, load_NE		: in std_logic;
			load_timer 			: in std_logic;
			load_etapa_atual		: in std_logic;
			load_ADDR_FLASH			: in std_logic;
			load_valvula			: in std_logic;
			load_MOTOR			: in std_logic;
			reset_all			: in std_logic;
			reset_NM			: in std_logic;
			reset_timer			: in std_logic;
			sel_1, sel_2			: in std_logic;
			sel_MUX4_0, sel_MUX4_1		: in std_logic;
			valv_1, valv_2			: in std_logic;
			alta_rot_motor			: in std_logic;
			baixa_rot_motor			: in std_logic;
			rot_horaria			: in std_logic;
			rot_anti_hor			: in std_logic;
			NM_Eq_0, NE_Eq_0		: out std_logic;
			PS_Menor_N			: out std_logic;
			P_Eq_01, P_Menor_01		: out std_logic;
			P_Eq_11, P_Menor_11		: out std_logic;
			timer_over			: out std_logic;
			ADDR_FLASH			: out std_logic_vector(3 downto 0);
			VALV_AGUA			: out std_logic_vector(1 downto 0);
			MOTOR				: out std_logic_vector(3 downto 0);
			D0, D1, D2, D3, D4 		: out std_logic_vector(6 downto 0);
			D5, D6, D7			: out std_logic_vector(6 downto 0)
			);
	end component;
	
	component Controladora is
		port (
			clk, clear, S, SN 		: in std_logic;
			NM_Eq_0, NE_Eq_0		: in std_logic;
			PS_Menor_N			: in std_logic;
			P_Eq_01, P_Menor_01		: in std_logic;
			P_Eq_11, P_Menor_11		: in std_logic;
			timer_over			: in std_logic;
			load_selection			: out std_logic;
			load_config			: out std_logic;
			load_NM, load_NE		: out std_logic;
			load_timer 			: out std_logic;
			load_etapa_atual		: out std_logic;
			load_ADDR_FLASH			: out std_logic;
			load_valvula			: out std_logic;
			load_MOTOR			: out std_logic;
			reset_all			: out std_logic;
			reset_NM			: out std_logic;
			reset_timer			: out std_logic;
			sel_1, sel_2			: out std_logic;
			sel_MUX4_0, sel_MUX4_1		: out std_logic;
			valv_1, valv_2			: out std_logic;
			alta_rot_motor			: out std_logic;
			baixa_rot_motor			: out std_logic;
			rot_horaria			: out std_logic;
			rot_anti_hor			: out std_logic;
			AF, BD				: out std_logic
		);
	end component;
	
	component MEMORIA_FLASH is
		port( 
			ADDR_FLASH			: in std_logic_vector (3 downto 0);
			DATA_FLASH			: out std_logic_vector (31 downto 0)
	    );
	end component;
	
	component div_clock_1Hz is
		port (
			CLOCK_50MHz 			: in std_logic;
			CLOCK_1Hz   			: out std_logic
		);
	end component;
	
	signal DATA 					: std_logic_vector(31 downto 0);
	signal ADDR 					: std_logic_vector(3 downto 0);
	signal clk_1Hz 					: std_logic;	
	signal load_selection				: std_logic;
	signal load_config				: std_logic;
	signal load_NM, load_NE				: std_logic;
	signal load_timer 				: std_logic;
	signal load_etapa_atual				: std_logic;
	signal load_ADDR_FLASH				: std_logic;
	signal load_valvula				: std_logic;
	signal load_MOTOR				: std_logic;
	signal reset_NM					: std_logic;
	signal reset_all				: std_logic;
	signal reset_timer				: std_logic;
	signal sel_1, sel_2				: std_logic;
	signal sel_MUX4_0, sel_MUX4_1			: std_logic;
	signal NM_Eq_0, NE_Eq_0				: std_logic;
	signal PS_Menor_N				: std_logic;
	signal P_Eq_01, P_Menor_01			: std_logic;
	signal P_Eq_11, P_Menor_11			: std_logic;
	signal timer_over				: std_logic;
	signal valv_1					: std_logic;
	signal valv_2					: std_logic;
	signal alta_rot_motor				: std_logic;
	signal baixa_rot_motor				: std_logic;
	signal rot_horaria				: std_logic;
	signal rot_anti_hor				: std_logic;
	
begin	
	DATA_PATH : Datapath
		port map(
			clk => clk_1Hz, ME => ME, EE => EE, P => P, N => N, PS => PS, 
			DATA_FLASH => DATA, valv_1 => valv_1, valv_2 => valv_2,					
			alta_rot_motor => alta_rot_motor, baixa_rot_motor => baixa_rot_motor,		
			rot_horaria => rot_horaria, rot_anti_hor => rot_anti_hor,			
			load_selection => load_selection, load_config =>load_config,		
			load_NM => load_NM, load_NE => load_NE, load_timer => load_timer,						
			load_etapa_atual => load_etapa_atual, load_ADDR_FLASH => load_ADDR_FLASH,			
			load_valvula => load_valvula, load_MOTOR => load_MOTOR, 
			reset_NM => reset_NM, reset_all => reset_all, reset_timer => reset_timer,				
			sel_1 => sel_1, sel_2 => sel_2, sel_MUX4_0 => sel_MUX4_0, sel_MUX4_1 => sel_MUX4_1,	
			NM_Eq_0 => NM_Eq_0, NE_Eq_0 => NE_Eq_0, PS_Menor_N => PS_Menor_N,	
			P_Eq_01 => P_Eq_01, P_Menor_01 => P_menor_01, P_Eq_11 => P_Eq_11, P_Menor_11 => P_Menor_11,	
			timer_over => timer_over, ADDR_FLASH => ADDR, VALV_AGUA => VALV_AGUA, MOTOR => MOTOR,
			D0 => D0, D1 => D1, D2	=> D2, D3 => D3, D4 => D4, D5 => D5, D6 => D6, D7 => D7			
		);
	CONTROLLER : Controladora
		port map(
			clk => clk_1Hz, S => S, SN => SN, clear => clear, timer_over => timer_over,
			NM_Eq_0 => NM_Eq_0, NE_Eq_0 => NE_Eq_0, PS_Menor_N => PS_Menor_N,	
			P_Eq_01 => P_Eq_01, P_Menor_01 => P_Menor_01, P_Eq_11 => P_Eq_11, P_Menor_11 => P_Menor_11, 
			sel_1 => sel_1, sel_2 => sel_2, sel_MUX4_0 => sel_MUX4_0, sel_MUX4_1 => sel_MUX4_1, 
			AF => AF, BD => BD, valv_1 => valv_1, valv_2 => valv_2,
			alta_rot_motor => alta_rot_motor, baixa_rot_motor => baixa_rot_motor,
			rot_horaria => rot_horaria, rot_anti_hor => rot_anti_hor,
			load_selection => load_selection, load_config => load_config, load_NM => load_NM, 
			load_NE => load_NE, load_etapa_atual => load_etapa_atual, load_timer => load_timer,		
			load_ADDR_FLASH => load_ADDR_FLASH, load_valvula => load_valvula, load_MOTOR => load_MOTOR, 
			reset_NM => reset_NM, reset_all => reset_all, reset_timer => reset_timer
		);
	MEMORIA : MEMORIA_FLASH
		port map(
			ADDR_FLASH => ADDR,
			DATA_FLASH => DATA
		);
	CLOCK : div_clock_1Hz
		port map(
			CLOCK_50MHz => clk_50Mhz,
			CLOCK_1Hz => clk_1Hz
		);
end RTL;
