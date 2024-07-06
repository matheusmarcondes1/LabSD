--trabalho final dig-elt029 ufmg
--rtl design: implementação de um sistema de controle de lavadora automatica de roupas
--autoria: breno augusto e gabriel groppo @ escola de engenharia ufmg
-- CONTROLADORA.vhd


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controladora is
	port (
		-- Inputs de periféricos externos
		clk, clear, S, SN 				: in std_logic;			-- S = start, SN = sensor de nivel d'agua
		-- Inputs que vem do Datapath
		NM_Eq_0, NE_Eq_0				: in std_logic;			-- NM_Eq_0 = ciclo(s) de molho concluido(s), NE_Eq_0 = ciclos de enxague concluidos
		PS_Menor_N					: in std_logic;			-- PS_Menor_N = nivel d'agua no tanque < nivel d'agua desejado
		P_Eq_01, P_Menor_01				: in std_logic;			-- P_Eq_01 = programa 01 (lavagem normal), P_Menor_01 = programa 00 (lavagem rapida)
		P_Eq_11, P_Menor_11				: in std_logic;			-- P_Eq_11 = programa 11 (enxague e centrifugacao apenas), P_Menor_11 = programa 10 (lavagem intensa)
		timer_over					: in std_logic;			-- fim do temporizador
		-- Outputs para o Datapath
		load_selection					: out std_logic;
		load_config					: out std_logic;
		load_NM, load_NE				: out std_logic;
		load_timer 					: out std_logic;
		load_etapa_atual				: out std_logic;
		load_ADDR_FLASH					: out std_logic;
		load_valvula					: out std_logic;
		load_MOTOR					: out std_logic;
		reset_all					: out std_logic;
		reset_NM					: out std_logic;
		reset_timer					: out std_logic;
		sel_1, sel_2					: out std_logic;
		sel_MUX4_0, sel_MUX4_1				: out std_logic;
		valv_1, valv_2					: out std_logic;
		alta_rot_motor					: out std_logic;
		baixa_rot_motor					: out std_logic;
		rot_horaria					: out std_logic;
		rot_anti_hor					: out std_logic;
		-- Outputs para periféricos
		AF, BD						: out std_logic			-- AF = atuador do freio, BD = bomba de drenagem
   );
end Controladora;

architecture RTL of Controladora is
	
	type state_type is (start, P_Rapida, P_Normal, 
	P_Intensa, P_Enxagua_Centrifuga, encher_valv1, 
	encher_valv2, atualiza_LV, atualiza_EN, 
	agitar_horario, agitar_anti_hor, atualiza_ML, 
	molho, drenagem, atualiza_CE, centrifugacao, fim);

	signal actual_state, next_state  : state_type;

begin
			
process (clk)
begin
	if clear = '1' 		then	actual_state 	<= start;
	
	elsif rising_edge(clk) 	then	actual_state 	<= next_state;
	
	end if;
		
end process;

process (actual_state, S, SN, timer_over, NM_Eq_0, NE_Eq_0, PS_Menor_N, P_Eq_01, P_Eq_11, P_Menor_01, P_Menor_11)
begin
	case actual_state is
	when start =>
		load_selection		<= '1';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_ADDR_FLASH		<= '1';
		load_MOTOR 		<= '0';
		load_valvula 		<= '0';
		reset_all		<= '1';
		reset_NM 		<= '1';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';

		if (S = '1' and P_Menor_01 = '1' and P_Eq_01 = '0' and P_Eq_11 = '0' and P_Menor_11 = '1') 	then	next_state 	<= P_Rapida;

		elsif (S = '1' and P_Menor_01 = '0' and P_Eq_01 = '1' and P_Eq_11 = '0' and P_Menor_11 = '1')	then	next_state 	<= P_Normal;

		elsif (S = '1' and P_Menor_01 = '0' and P_Eq_01 = '0' and P_Eq_11 = '0' and P_Menor_11 = '1')	then	next_state 	<= P_Intensa;

		elsif (S = '1' and P_Menor_01 = '0' and P_Eq_01 = '0' and P_Eq_11 = '1' and P_Menor_11 = '0')	then	next_state 	<= P_Enxagua_Centrifuga;

								else							next_state 	<= start;

		end if;
		
	when P_Rapida =>
		load_selection		<= '0';
		load_config      	<= '1';
		load_NM 		<= '1';
		load_NE 		<= '1';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '1';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all         	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state 		<= encher_valv1;
		
	when P_Normal =>
		load_selection		<= '0';
		load_config       	<= '1';
		load_NM 		<= '1';
		load_NE 		<= '1';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '1';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all         	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state 		<= encher_valv1;
		
	when P_Intensa =>
		load_selection		<= '0';
		load_config       	<= '1';
		load_NM 		<= '1';
		load_NE 		<= '1';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '1';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all	        <= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state 		<= encher_valv1;
		
	when P_Enxagua_Centrifuga =>
		load_selection		<= '0';
		load_config       	<= '1';
		load_NM 		<= '1';
		load_NE 		<= '1';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '1';
		load_valvula 		<= '0';
		reset_NM 		<= '1';
		reset_all         	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state 		<= encher_valv2;
		
	when encher_valv1 =>
		load_selection		<= '0'; 
		load_config		<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '1';
		reset_NM 		<= '0';
		reset_all       	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '1';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';

		if (PS_Menor_N = '1') then		next_state 	<= encher_valv1;

		else					next_state 	<= atualiza_LV;

		end if;
		
	when encher_valv2 =>
		load_selection		<= '0';
		load_config		<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '1';
		reset_NM 		<= '0';
		reset_all         	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '1';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';

		if (PS_Menor_N = '1') then		next_state 	<= encher_valv2;

		else					next_state 	<= atualiza_EN;

		end if;
		
	when atualiza_LV =>
		load_selection		<= '0';
		load_config      	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '0';
		load_etapa_atual 	<= '1';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '1';
		reset_NM 		<= '0';
		reset_all         	<= '0';
		reset_timer 		<= '1';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state 		<= agitar_horario;
		
	when atualiza_EN =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '1';
		load_timer 		<= '0';
		load_etapa_atual 	<= '1';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '1';
		reset_NM 		<= '0';
		reset_all         	<= '0';
		reset_timer 		<= '1';
		sel_1 			<= '0';
		sel_2 			<= '1';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state 		<= agitar_horario;
		
	when agitar_horario =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '1';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '1';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all       	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor		<= '1';
		rot_horaria		<= '1';
		rot_anti_hor		<= '0';

		if (timer_over = '1' and NM_Eq_0 = '1') 	then	next_state	<= drenagem;

		elsif (timer_over = '1' and NM_Eq_0 = '0') 	then	next_state 	<= atualiza_ML;

		else							next_state 	<= agitar_anti_hor;

		end if;
		
	when agitar_anti_hor =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '1';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '1';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all       	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor		<= '1';
		rot_horaria		<= '0';
		rot_anti_hor		<= '1';

		if (timer_over = '1' and NM_Eq_0 = '1') 	then	next_state	<= drenagem;

		elsif (timer_over = '1' and NM_Eq_0 = '0') 	then	next_state 	<= atualiza_ML;

		else							next_state 	<= agitar_horario;	

		end if;
					
	when atualiza_ML =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '1';
		load_NE 		<= '0';
		load_timer 		<= '0';
		load_etapa_atual 	<= '1';
		load_MOTOR 		<= '1';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all         	<= '0';
		reset_timer 		<= '1';
		sel_1 			<= '1';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '1';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state <= molho;
		
	when molho =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '1';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '1';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all         	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '1';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';

		if (timer_over = '0') 	then	next_state 	<= molho;

		else				next_state 	<= atualiza_LV;

		end if;
		
	when drenagem =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '1';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all         	<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '1';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';

		if (SN = '0' and NE_Eq_0 = '1') 	then	next_state	<= atualiza_CE;

		elsif (SN = '0' and NE_Eq_0 = '0') 	then	next_state 	<= encher_valv2;

		else						next_state 	<= drenagem;

		end if;
		
	when atualiza_CE =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '0';
		load_etapa_atual 	<= '1';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all 		<= '0';
		reset_timer 		<= '1';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '1';
		sel_MUX4_1 		<= '1';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state 		<= centrifugacao;
		
	when centrifugacao =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '1';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '1';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '0';
		reset_NM 		<= '0';
		reset_all 		<= '0';
		reset_timer 		<= '0';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '1';
		sel_MUX4_1 		<= '1';
		BD			<= '1';
		AF			<= '1';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '1';
		baixa_rot_motor 	<= '0';
		rot_horaria		<= '1';
		rot_anti_hor 		<= '0';

		if (timer_over = '0') 	then	next_state 	<= centrifugacao;

		else				next_state 	<= fim;

		end if;
		
	when fim =>
		load_selection		<= '0';
		load_config       	<= '0';
		load_NM 		<= '0';
		load_NE 		<= '0';
		load_timer 		<= '0';
		load_etapa_atual 	<= '0';
		load_MOTOR 		<= '0';
		load_ADDR_FLASH 	<= '0';
		load_valvula 		<= '0';
		reset_NM 		<= '1';
		reset_all 		<= '1';
		reset_timer 		<= '1';
		sel_1 			<= '0';
		sel_2 			<= '0';
		sel_MUX4_0 		<= '0';
		sel_MUX4_1 		<= '0';
		AF 			<= '0';
		BD 			<= '0';
		valv_1 			<= '0';
		valv_2 			<= '0';
		alta_rot_motor 		<= '0';
		baixa_rot_motor 	<= '0';
		rot_horaria 		<= '0';
		rot_anti_hor 		<= '0';
		next_state 		<= start;
		
--	when others =>
--		load_selection		<= '0';
--		load_config       	<= '0';
--		load_NM 		<= '0';
--		load_NE 		<= '0';
--		load_timer 		<= '0';
--		load_etapa_atual 	<= '0';
--		load_MOTOR 		<= '0';
--		load_ADDR_FLASH 	<= '0';
--		load_valvula 		<= '0';
--		reset_NM 		<= '1';
--		reset_all 		<= '1';
--		reset_timer 		<= '1';
--		sel_1 			<= '0';
--		sel_2 			<= '0';
--		sel_MUX4_0 		<= '0';
--		sel_MUX4_1 		<= '0';
--		AF 			<= '0';
--		BD 			<= '0';
--		valv_1 			<= '0';
--		valv_2 			<= '0';
--		alta_rot_motor 		<= '0';
--		baixa_rot_motor 	<= '0';
--		rot_horaria 		<= '0';
--		rot_anti_hor 		<= '0';
--		next_state 		<= start;

	end case;
end process;
end RTL;
