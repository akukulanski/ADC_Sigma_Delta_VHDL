----------------------------------------------------------------------------------
-- Company: DPLAB
-- Engineer: Andres Demski
-- 
-- Create Date:    14:02:37 08/29/2014 
-- Design Name: Top Level - UART
-- Module Name:    UART - Behavioral 
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


entity UART is
	generic (
		Core : integer := 50000000; -- Frecuencia de core
		BaudRate : integer := 9600; -- BaudRate
		Bits : integer := 8  -- Cantidad de Bits
	);
	
	port(
		Tx_o : out std_logic;  -- Tx
		Load : in std_logic_vector (Bits-1 downto 0); --Datos a enviar
		LE : in std_logic;  -- Cargar datos al Tx
		TxEmpty : out std_logic; --Tx vacio
		
		Rx_in : in std_logic; -- Rx
		Rx_Data : out std_logic_vector (Bits-1 downto 0); --Datos Recibidos 
		Rx_Parity : out std_logic; -- Rx Paridad
		RxFinish : out std_logic; --Termino la recepción
		
		Rst : in std_logic; --Reset
		Clk : in std_logic --Clk
	); 

end UART;

architecture Behavioral of UART is

impure function CalcValue_Frec (Core: Integer; BaudRate: Integer) return Integer is
begin
   return (Core/(BaudRate*13));
end CalcValue_Frec;


component Tx is
	generic ( N : integer :=8;
		  M : integer :=4
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
end component;

component Rx 
	generic ( N : integer := 8; 
				M : integer :=4 
		);
	port (
		output : out std_logic_vector (N-1 downto 0);
		input : in std_logic;
		finish : out std_logic;
		parity : out std_logic;
		CE : in std_logic;
		rst : in std_logic;
		clk : in std_logic
		);
end component;

component RisingEdgeDet is
	port (
				i : in std_logic;
				q : out std_logic;
				rst : in std_logic;
				clk : in std_logic;
				CE : in std_logic
			);
end component;

signal TxEmpty_i : std_logic:='1';
signal Tx_input : std_logic_vector (Bits-1 downto 0) := (others=>'0');
signal Tx_start : std_logic := '0';
signal Tx_finish : std_logic := '0';
signal Tx_Finish_Edge : std_logic := '0';
signal Tx_input_i : std_logic_vector (Bits-1 downto 0) := (others=>'0');
signal Tx_start_i : std_logic := '0';
signal Start_End : std_logic := '0';
signal CE : std_logic := '1';

signal Start_cnt : integer range 0 to ( CalcValue_Frec(Core, BaudRate) ) := 0;

type state_type is (st_waiting, st_start, st_Sending); 
signal state, next_state : state_type; 
 
begin
	
   TX_SYNC_PROC: process (Clk)
   begin
      if (rising_edge(clk)) then
         if (Rst = '1') then
            state <= st_waiting;
            Tx_input <= (others => '0') ;
            Tx_start <= '0';
            TxEmpty <= '1';
         else
            state <= next_state;
            Tx_input <= Tx_input_i ;
            Tx_start <= Tx_start_i;
            TxEmpty <= TxEmpty_i;
         end if;        
      end if;
   end process;
 
   TX_OUTPUT_DECODE: process (state, Tx_Finish_Edge, LE , Load, Tx_input, Start_End)
   begin
	case (state) is
		when st_waiting =>
			if (LE='1') then
				Tx_input_i <= Load;
				Tx_start_i <= '1';
				TxEmpty_i <='0';
			else 
				Tx_input_i <= (others=>'0');
				Tx_start_i <= '0';
				TxEmpty_i <= '1';
			end if;
		when st_start =>
			if (Start_End = '1') then
				Tx_input_i <= Tx_input;
				Tx_start_i <= '0';
				TxEmpty_i <='0';
			else
				Tx_input_i <= Tx_input;
				Tx_start_i <= '1';
				TxEmpty_i <='0';
			end if;
			
		when st_Sending =>
			if (Tx_Finish_Edge ='1') then
				Tx_input_i <= (others=>'0');
				Tx_start_i <= '0';
				TxEmpty_i <='1';
			else
				Tx_input_i <= Tx_input;
				Tx_start_i <= '0';
				TxEmpty_i <='0';
			end if;
		when others =>
			Tx_input_i <= (others=>'0');
			Tx_start_i <= '0';
			TxEmpty_i <= '1';
	end case;   
   end process;
 
 TX_NEXT_STATE_DECODE: process (state, Tx_Finish_Edge, LE , Start_End)
   begin
      next_state <= state;
     case (state) is
         when st_waiting =>
         	if (LE = '1') then
         		next_state <= st_start;
         	end if;
 	 when st_start =>
		if (Start_End = '1') then
			next_state <= st_Sending;
		end if;
        	
         when st_Sending =>
         	if (Tx_Finish_Edge = '1') then
         		next_state <= st_waiting;
         	end if;
         when others =>
            next_state <= st_waiting;
      end case;      
   end process;	
	
	
TRANSMISOR: Tx generic map ( 
			N => Bits,
			M => 4
			)
		port map(
			input => Tx_input,
			start => Tx_start,
			output => Tx_o,
			finish => Tx_Finish,
			Rst => Rst,
			Clk => clk,
			CE => CE
			);
			
RECEPTOR: Rx 
	generic map ( N => Bits, M => 4	) 
	port map (
		output =>  Rx_Data,
		input => Rx_in,
		finish => RxFinish,
		parity => Rx_Parity ,
		CE => CE,
		rst => Rst,
		clk => clk
		);


FINISHEDGE: RisingEdgeDet port map(
				i => Tx_Finish,
				q => Tx_Finish_Edge,
				Rst => Rst,
				clk => Clk,
				CE => '1'
			);


process (Clk)
variable cnt : integer range 0 to CalcValue_Frec(Core,BaudRate):= 0;
begin
	if (rising_edge(clk)) then
		if (cnt = CalcValue_Frec(Core,BaudRate)) then
			cnt :=0;
			CE <= '1';
		else
			cnt := cnt +1;
			CE <='0';
		end if;
	end if;
end process;

START_PROCESS: process (Clk)
begin
	if (rising_edge(clk)) then
		if (Tx_start_i = '1') then
			if (Start_cnt  = CalcValue_Frec(Core, BaudRate) ) then
				Start_cnt  <=0;
				Start_End <= '1';
			else
				Start_cnt  <= Start_cnt  +1;
				Start_End <='0';
			end if;
		else
			Start_cnt  <= 0;
			Start_End <='0';
		end if;
	end if;
end process;



	

end Behavioral;

