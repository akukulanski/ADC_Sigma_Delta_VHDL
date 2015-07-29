----------------------------------------------------------------------------------
-- Company: DPLAB
-- Engineer: Andres Demski
-- 
-- Create Date:    17:50:59 08/24/2014 
-- Design Name: Transmisor UART
-- Module Name:    Tx - Behavioral 
-- Project Name: UART
-- Target Devices: MOJOv3
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Tx is
	generic ( N : integer :=8;  -- Cantidad de Bits
		  M : integer :=4      -- Divisor de frecuencia
		);
	port (
			input : in std_logic_vector (N-1 downto 0);
			start : in std_logic;
			output : out std_logic;
			finish : out std_logic;
			Rst : in std_logic;
			Clk : in std_logic;
			CE : in std_logic
			);
end Tx;

architecture Behavioral of Tx is


constant Comp : std_logic_vector (M-1 downto 0) := "1010";

component Counter is
	generic (
				N : integer := 3
				);
	port (
			Finish : out std_logic;
			Enable : in std_logic;
			Rst : in std_logic;
			Cmp : in std_logic_vector (N-1 downto 0);
			Clk : in std_logic;
			CE : in std_logic
			);
end component;

component Paridad is
	generic (
					N : integer := 8
					);
	port (
				input : in std_logic_vector (N-1 downto 0);
				p : out std_logic
				);
end component;


	type state_type is (st_waiting, st_start, st_sending, st_parity, st_stop); 
	signal state, next_state : state_type; 

	signal finish_i : std_logic;
   	signal output_i : std_logic;
	
	signal index : integer range 0 to N-1:=0;
	signal index_i : integer range 0 to N-1:=0;
	signal index_inc : integer range 0 to N-1:=0;
	
	
	signal parity : std_logic := '0';
	
	signal TEnable : std_logic := '0';
	signal TReset : std_logic := '0';
	signal TFinish : std_logic := '0';
	
	signal TEnable_i : std_logic := '0';
	signal TReset_i : std_logic := '0';
	
begin

	SYNC_PROC: process (Clk)
   begin
      if (rising_edge(Clk)) then
      	if (CE = '1') then 
		 if (Rst = '1') then
			state <= st_waiting;
			output <='1';
			finish <= '0';
			TEnable <= '0';
			TReset <='1';
		 else
			state <= next_state;
			output <= output_i;
			TEnable <= TEnable_i;
			TReset <= TReset_i;
			index <= index_i;
			finish <= finish_i;
		 end if;        
         end if;
      end if;
   end process;
 
   OUTPUT_DECODE: process (state, TFinish, input, start,index, index_inc, parity)
   begin
		case (state) is
			when (st_waiting) =>
				if (start = '1') then
					output_i <= '0';
					TEnable_i <= '1';
					TReset_i <= '1';
					index_i <= 0;
					finish_i <= '0';
				else				
					output_i <= '1';
					TEnable_i <= '0';
					TReset_i <= '0';
					index_i <= 0;
					finish_i <= '0';
				end if;
			when (st_start) =>
				if (TFinish = '1') then
					output_i <= input(index);
					TEnable_i <= '1';
					TReset_i <='1';
					index_i <= 0;
					finish_i <= '0';
				else
					output_i <= '0';
					TEnable_i <= '1';
					TReset_i <='0';
					index_i <= 0;
					finish_i <= '0';
				end if;
			when (st_sending) =>
				if (TFinish = '1') then
					if (index = N-1) then
						output_i <= parity;
						TEnable_i <= '1';
						TReset_i <='1';
						index_i <= 0;
						finish_i <= '0';
					else
						output_i <= input(index_inc);
						TEnable_i <= '1';
						TReset_i <='1';
						index_i <= index_inc;
						finish_i <= '0';
					end if;				
				else
					output_i <= input(index);
					TEnable_i <= '1';
					TReset_i <='0';
					index_i <= index;
					finish_i <= '0';
				end if;
			
			when (st_parity) =>
				if (TFinish = '1') then
					output_i <= '1';
					TEnable_i <= '0';
					TReset_i <='1';
					index_i <= 0;
					finish_i <= '0';
				else
					output_i <= parity;
					TEnable_i <= '1';
					TReset_i <='0';
					index_i <= 0;
					finish_i <= '0';
				end if;
			
			when (st_stop) =>
				if (TFinish = '1') then
					output_i <= '1';
					TEnable_i <= '0';
					TReset_i <='1';
					index_i <= 0;
					finish_i <= '1';
				else
					output_i <= '1';
					TEnable_i <= '1';
					TReset_i <='0';
					index_i <= 0;
					finish_i <= '0';
				end if;
			
			when others =>
					output_i <= '1';
					TEnable_i <= '0';
					TReset_i <='1';
					index_i <= 0;
					finish_i <= '0';
		end case;
   end process;
 
   NEXT_STATE_DECODE: process (state, start, TFinish, index)
   begin
      next_state <= state;  
		
      case (state) is
		
         when st_waiting =>
            if start = '1' then
               next_state <= st_start;
            end if;
				
         when st_start =>
            if TFinish = '1' then
               next_state <= st_sending;
            end if;
        
         when st_sending =>
			if ( (TFinish='1') and (index=N-1) ) then
				next_state <= st_parity;
			end if;
        
         when st_parity =>
            if TFinish = '1' then
               next_state <= st_stop;
            end if;
			
         when st_stop =>
            if TFinish = '1' then
               next_state <= st_waiting;
            end if;
        
         when others =>
            next_state <= st_waiting;
      end case;      
   end process;

	Timer : Counter
						generic map(
										N => M
										)
						port map(
									Finish => TFinish,
									Enable => TEnable,
									Rst => TReset,
									Cmp => Comp,
									Clk =>Clk,
									CE => CE
									
									);
	par: Paridad generic map (	N => N )
					 port map (	input => input ,
									p => parity	);	
	
	index_inc <= index + 1;

end Behavioral;

