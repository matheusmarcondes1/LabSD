LIBRARY IEEE;
use ieee.std_logic_1164.all;

entity Datapath is
	port(
		-- Inputs de periféricos externos
		clk, ME, EE					: in std_logic;
		P, N, PS						: in std_logic_vector(1 downto 0);
		DATA_FLASH					: in std_logic_vector(31 downto 0);
		-- Inputs que vem da controladora
		load_selection				: in std_logic;
		load_config					: in std_logic;
		load_NM, load_NE			: in std_logic;
		load_timer 					: in std_logic;
		load_etapa_atual			: in std_logic;
		load_ADDR_FLASH			: in std_logic;
		load_valvula				: in std_logic;
		load_MOTOR					: in std_logic;
		reset_all					: in std_logic;
		reset_NM						: in std_logic;
		reset_timer					: in std_logic;
		sel_1, sel_2				: in std_logic;
		sel_MUX4_0, sel_MUX4_1	: in std_logic;
		valv_1, valv_2				: in std_logic;
		alta_rot_motor				: in std_logic;
		baixa_rot_motor			: in std_logic;
		rot_horaria					: in std_logic;
		rot_anti_hor				: in std_logic;
		-- Outputs para a controladora
		NM_Eq_0, NE_Eq_0			: out std_logic;
		PS_Menor_N					: out std_logic;
		P_Eq_01, P_Menor_01		: out std_logic;
		P_Eq_11, P_Menor_11		: out std_logic;
		timer_over					: out std_logic;
		-- Outputs para periféricos
		ADDR_FLASH					: out std_logic_vector(3 downto 0);
		VALV_AGUA					: out std_logic_vector(1 downto 0);
		MOTOR							: out std_logic_vector(3 downto 0);
		D0, D1, D2, D3, D4 		: out std_logic_vector(6 downto 0);
		D5, D6, D7					: out std_logic_vector(6 downto 0)
	);
end Datapath;

architecture RTL of Datapath is
	
	-- Declarações de componentes
	
	component Reg_Generic is	
		Generic(
			DATA_WIDTH : natural := 4
		);
		Port( 
			clock, reset, load : in std_logic;
			D						 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
			Q						 : out std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0')
		);
	end component;
	
	component Comparador is
		Generic(
			DATA_WIDTH : natural := 4
		);
		Port (
			A, B 						: in std_logic_vector(DATA_WIDTH - 1 downto 0);
			MAIOR, MENOR, IGUAL 	: out std_logic
		);
	end component;
	
	component Comparador_Eq_0 is
		Generic (
			DATA_WIDTH : natural := 8
		);
		Port (
			A		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
			A_Eq_0 : out std_logic
		);
	end component;
	
	component mux_4 is
		Generic (
			Size : natural := 6
		);	
		Port (
			A, B, C, D : in std_logic_vector(Size-1 downto 0);
			sel 		  : in std_logic_vector(1 downto 0);
			result 	  : out std_logic_vector(Size-1 downto 0)
	);
	end component;
	
	component mux_2 is
		Generic (
			Size : natural := 6
		);	
		Port (
			A, B 	  	: in std_logic_vector(Size-1 downto 0);
			sel 		: in std_logic;
			result 	: out std_logic_vector(Size-1 downto 0)
	);
	end component;
	
	component somador is
		Generic (
			DATA_WIDTH : natural := 8
		);
		Port (
			a, b	   : in std_logic_vector	((DATA_WIDTH-1) downto 0);
			result   : out std_logic_vector 	((DATA_WIDTH-1) downto 0)
		);
	end component;
	
	component decrementador is
		Port(
			A   		: in   	std_logic_vector(1 downto 0);
			result 	: out		std_logic_vector(1 downto 0)
		);
	end component;
	
	component Incrementador is
		Generic(
			DATA_WIDTH : natural := 4
		);
		Port(
			A   		: in   	std_logic_vector(DATA_WIDTH-1 downto 0);
			result 	: out		std_logic_vector(DATA_WIDTH-1 downto 0)
		);
	end component;
	
	component Temporizador is
		Port (
		  clk, reset, load : in std_logic;
        entrada          : in std_logic_vector(5 downto 0);
        saida            : out std_logic := '0';
        timer            : out std_logic_vector(5 downto 0)
		 );
	end component;
	
	component Conversor_Display is
		Port (
        tempo 		: in std_logic_vector(5 downto 0);
        display_1 : out std_logic_vector(3 downto 0);  
		  display_2 : out std_logic_vector(3 downto 0)  
    );
	end component;
	
	component BCD_7seg is
		port (
			entrada		: in std_logic_vector (3 downto 0);
			saida			: out std_logic_vector (6 downto 0)
		);
	end component;

	signal dontcares_outs : std_logic;
	-- Sinais auxiliares para registradores
	signal no_reset 									: std_logic := '0';
	signal out_P, out_N, out_NM, out_NE 		: std_logic_vector(1 downto 0);
	signal out_TL, out_TM, out_TE, out_TC 		: std_logic_vector(5 downto 0);
	signal TL, TE, TC, TM 							: std_logic_vector(5 downto 0);
	signal out_num_etapas, out_etapa_atual 	: std_logic_vector(3 downto 0);
	signal MOTOR_in, ADDR_in						: std_logic_vector(3 downto 0);
	signal VALV_in 									: std_logic_vector(1 downto 0);
	-- Sinais auxiliares para somadores
	signal NM, NE										: std_logic_vector(1 downto 0);
	signal num_etapas 								: std_logic_vector(3 downto 0);
	signal in_B_somador_1, in_B_somador_2 		: std_logic_vector(1 downto 0);
	signal out_somador_1, out_somador_2 		: std_logic_vector(1 downto 0);
	signal in_B_somador_3, out_somador_3		: std_logic_vector(3 downto 0);
	-- Sinais auxiliares para multiplexadores
	signal out_mux2_1, out_mux2_2, sel_MUX4 	: std_logic_vector(1 downto 0);
	signal out_mux4 									: std_logic_vector(5 downto 0);
	-- Sinais auxiliares para decrementadores e incrementadores
	signal out_decrementador_1 					: std_logic_vector(1 downto 0);
	signal out_decrementador_2 					: std_logic_vector(1 downto 0);
	signal out_incrementa 							: std_logic_vector(3 downto 0);
	-- Sinais auxiliares para comparadores
	signal in_B_comp1, in_B_comp2 				: std_logic_vector(1 downto 0);
	-- Sinais auxiliares para conversores p/ display
	signal in_Conversor_1, in_Conversor_2 		: std_logic_vector(5 downto 0);
	signal out1_Conversor_1, out2_Conversor_1 : std_logic_vector(3 downto 0);
	signal out1_Conversor_2, out2_Conversor_2 : std_logic_vector(3 downto 0);
	signal out1_Conversor_3, out2_Conversor_3 : std_logic_vector(3 downto 0);
	-- Sinal auxiliar saída "timer" para o temporizador 
	signal out_timer : std_logic_vector(5 downto 0);
	-- Sinais auxiliares para display 7 segmentos
	signal NM_BCD, NE_BCD : std_logic_vector(3 downto 0);
	
begin
	-- Atribuição do barramento de 32 bits da memória para os registradores correspondentes
	TL 			<= DATA_FLASH(5 downto 0);
	TE 			<= DATA_FLASH(11 downto 6);
	TM 			<= DATA_FLASH(17 downto 12);
	TC 			<= DATA_FLASH(23 downto 18);
	NM 			<= DATA_FLASH(25 downto 24);
	NE				<= DATA_FLASH(27 downto 26);
	num_etapas 	<= DATA_FLASH(31 downto 28);
	-- Agrupando std_logic para std_logic_vector
	MOTOR_in 		<= (alta_rot_motor & baixa_rot_motor & rot_anti_hor & rot_horaria);
	VALV_in 			<= (valv_2 & valv_1);
	ADDR_in 			<= ("00" & out_P);
	in_B_comp1 		<= "01";
	in_B_comp2 		<= "11";
	in_B_somador_1 <= '0' & ME;
	in_B_somador_2 <= '0' & EE;
	in_B_somador_3 <= "00" & ME & EE;
	in_Conversor_1 <= "00" & out_etapa_atual;
	in_Conversor_2 <= "00" & out_num_etapas;
	sel_MUX4(0) 	<= sel_MUX4_0;
	sel_MUX4(1) 	<= sel_MUX4_1;
	NM_BCD			<= "00" & out_NM;
	NE_BCD			<= "00" & out_NE;
	
	-- Instanciação de todos componentes necessários
	Reg_P : Reg_Generic
		Generic map (DATA_WIDTH => 2)
		Port map(
			clock	=> clk,
			reset	=> no_reset,
			load	=>	load_selection,
			D		=>	P,
			Q		=> out_P
		);
	Reg_N : Reg_Generic
		Generic map (DATA_WIDTH => 2)
		Port map(
			clock	=> clk,
			reset	=> no_reset,
			load	=> load_selection,
			D		=> N,
			Q		=> out_N
		);
	Reg_NM : Reg_Generic
		Generic map (DATA_WIDTH => 2)
		Port map(
			clock	=> clk,
			reset	=> reset_NM,
			load	=> load_NM,
			D		=> out_mux2_1,
			Q		=> out_NM
		);
	Reg_NE : Reg_Generic
		Generic map (DATA_WIDTH => 2)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_NE,
			D		=> out_mux2_2,
			Q		=> out_NE
		);
	Reg_TL : Reg_Generic
		Generic map (DATA_WIDTH => 6)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_config,
			D		=> TL,
			Q		=> out_TL
		);
	Reg_TM : Reg_Generic
		Generic map (DATA_WIDTH => 6)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_config,
			D		=> TM,
			Q		=> out_TM
		);
	Reg_TE : Reg_Generic
		Generic map (DATA_WIDTH => 6)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_config,
			D		=> TE,
			Q		=> out_TE
		);
	Reg_TC : Reg_Generic
		Generic map (DATA_WIDTH => 6)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_config,
			D		=> TC,
			Q		=> out_TC
		);
	Num_Etapa : Reg_Generic
		Generic map (DATA_WIDTH => 4)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_config,
			D		=> out_somador_3,
			Q		=> out_num_etapas
		);
	Etapa_Atual : Reg_Generic
		Generic map (DATA_WIDTH => 4)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_etapa_atual,
			D		=> out_incrementa,
			Q		=> out_etapa_atual
		);
	MOTOR_0 : Reg_Generic
		Generic map (DATA_WIDTH => 4)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_MOTOR,
			D		=> MOTOR_in,
			Q		=> MOTOR
		);
	VALVULA : Reg_Generic
		Generic map (DATA_WIDTH => 2)
		Port map(
			clock	=> clk,
			reset	=> reset_all,
			load	=> load_valvula,
			D		=> VALV_in,
			Q		=> VALV_AGUA
		);
	ADDR : Reg_Generic
		Generic map (DATA_WIDTH => 4)
		Port map(
			clock	=> clk,
			reset	=> no_reset,
			load	=> load_ADDR_FLASH,
			D		=> ADDR_in,
			Q		=> ADDR_FLASH
		);
	Comparador_1 : Comparador
		Generic map (DATA_WIDTH => 2)
		Port map(
			A 		=> out_P,
			B 		=> in_B_comp1,
			MENOR => P_menor_01,
			IGUAL => P_eq_01,
			MAIOR => dontcares_outs
		);	
	Comparador_2 : Comparador
		Generic map (DATA_WIDTH => 2)
		Port map(
			A 		=> out_P,
			B 		=>	in_B_comp2,
			MENOR => P_menor_11,
			IGUAL => P_eq_11,
			MAIOR => dontcares_outs
		);	
	Comparador_3 : Comparador
		Generic map (DATA_WIDTH => 2)
		Port map(
			A 		=> PS,
			B 		=> out_N,
			MENOR => PS_Menor_N,
			IGUAL => dontcares_outs,
			MAIOR => dontcares_outs
		);
	Comp_Eq_0_1 : Comparador_Eq_0
		Generic map (DATA_WIDTH => 2)
		Port map(
			A 		 => out_NM,
			A_Eq_0 => NM_Eq_0
		);
	Comp_Eq_0_2 : Comparador_Eq_0
		Generic map (DATA_WIDTH => 2)
		Port map(
			A 		 => out_NE,
			A_Eq_0 => NE_Eq_0
		);
	MUX2_1 : mux_2
		Generic map(Size => 2)
		Port map(
			A 		 => out_somador_1,
			B 		 => out_decrementador_1,
			sel 	 => sel_1,
			result => out_mux2_1
		);
	MUX2_2: mux_2
		Generic map(Size => 2)
		Port map(
			A 		 => out_somador_2,
			B 		 => out_decrementador_2,
			sel 	 => sel_2,
			result => out_mux2_2
		);
	MUX4 : mux_4
		Generic map(Size => 6)
		Port map(
			A 		 => out_TL,
			B 		 => out_TE,
			C		 => out_TM,
			D		 => out_TC,
			sel 	 => sel_MUX4,
			result => out_mux4
		);
	Timer : Temporizador
		Port map(
			 clk 		=> clk, 
			 reset 	=> reset_timer,
			 load 	=> load_timer,   
			 entrada => out_mux4,           
			 saida 	=> timer_over,         
			 timer 	=> out_timer             
		);
	decrementador_1 : decrementador
		Port map(
			A 		 => out_NM,
			result => out_decrementador_1
		);
	decrementador_2 : decrementador
		Port map(
			A 		 =>  out_NE,
			result => out_decrementador_2
		);
	Incrementador_1 : Incrementador
		Generic map(DATA_WIDTH => 4)
		Port map(
			A 		 => out_etapa_atual,
			result => out_incrementa
		);
	Somador_1 : somador
		Generic map (DATA_WIDTH => 2)
		Port map(
			a 		 => NM,
			b 		 => iN_B_somador_1,
			result => out_somador_1
		);
	Somador_2 : somador
		Generic map (DATA_WIDTH => 2)
		Port map(
			a 		 => NE,
			b 		 => in_B_somador_2,
			result => out_somador_2
		);
	Somador_3 : somador
		Generic map (DATA_WIDTH => 4)
		Port map(
			a 		 => num_etapas,
			b 		 => in_B_somador_3,
			result => out_somador_3
		);
	Conversor_Display_1 : Conversor_Display
		Port map(
			tempo		 => in_Conversor_1,
			display_1 => out1_Conversor_1,
			display_2 => out2_Conversor_1
		);
	Conversor_Display_2 : Conversor_Display
		Port map(
			tempo		 => in_Conversor_2,
			display_1 => out1_Conversor_2,
			display_2 => out2_Conversor_2
		);
	Conversor_Display_3: Conversor_Display
		Port map(
			tempo		 => out_timer,
			display_1 => out1_Conversor_3,
			display_2 => out2_Conversor_3
		);
	BCD_0_UN : BCD_7seg
		Port map(
			entrada => out1_Conversor_1,
			saida	  => D0
		);
	BCD_1_DZ : BCD_7seg
		Port map(
			entrada => out2_Conversor_1,
			saida	  => D1
		);
	BCD_2_A : BCD_7seg
		Port map(
			entrada => NM_BCD,
			saida	  => D2
		);
	BCD_3_E : BCD_7seg
		Port map(
			entrada => NE_BCD,
			saida	  => D3
		);
	BCD_4_UN : BCD_7seg
		Port map(
			entrada => out1_Conversor_2,
			saida	  => D4
		);
	BCD_5_DZ : BCD_7seg
		Port map(
			entrada => out2_Conversor_2,
			saida	  => D5
		);
	BCD_6_UN : BCD_7seg
		Port map(
			entrada => out1_Conversor_3,
			saida	  => D6
		);
	BCD_7_DZ : BCD_7seg
		Port map(
			entrada => out2_Conversor_3,
			saida	  => D7
		);
end RTL;