----------------------------------------------------------------------------------
-- Company: DPLAB
-- Engineer: Andres Demski
-- 
-- Create Date:    23:50:55 08/25/2014 
-- Design Name: Receptor Uart
-- Module Name:    Rx - Behavioral 
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

entity Rx is
	generic ( N : integer := 8;   -- Cantidad de Bits
				M : integer :=4   -- Divisor de frecuencia 
		);
	port (
		output : out std_logic_vector (N-1 downto 0);  -- Dato adquirido
		input : in std_logic;  -- Entrada serie
		finish : out std_logic;  -- Finish Rx
		parity : out std_logic;  -- Paridad
		CE : in std_logic;  -- Clock Enable
		rst : in std_logic;  -- Rst
		clk : in std_logic  -- Clk
		);
end Rx;

architecture Behavioral of Rx is

constant Comp : std_logic_vector (M-1 downto 0) := "1010";

component EdgeDetector is
	port (
				i : in std_logic;
				q : out std_logic;
				CE : in std_logic;
				rst : in std_logic;
				clk : in std_logic
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

component sync is
	port (
			meta_data : in std_logic;
			sync_data : out std_logic;
			clk : in std_logic;
			rst: in std_logic
			);
end component;



signal receive : std_logic_vector (N-1 downto 0):= (others=>'0');
signal receive_tmp : std_logic_vector (N-1 downto 0):= (others=>'0');

signal RFinish_i : std_logic:='0';


signal TEnable : std_logic:= '0';
signal TReset : std_logic:= '0';
signal TFinish : std_logic:= '0';
signal TComp : std_logic_vector (M-1 downto 0):='0'& Comp(M-1 downto 1);

signal TEnable_i : std_logic:= '0';
signal TReset_i : std_logic:= '0';
signal TComp_i : std_logic_vector (M-1 downto 0):='0'& Comp(M-1 downto 1);

signal Edge : std_logic := '0'; 
signal Sync_in : std_logic := '0';

signal Index : integer range 0 to N-1:=0;
signal Index_i : integer range 0 to N-1:=0;
signal Index_inc : integer range 0 to N-1:=0;

type state_type is (st_waiting,st_start, st_recibiendo, st_parity, st_stop); 
signal state, next_state : state_type; 



begin
 
SYNC_PROC: process ( Clk )
begin
	if ( rising_edge(Clk) ) then
		if ( Rst = '1') then
			TEnable <= '0';
			TReset <= '0';
			TComp <= '0'& Comp(M-1 downto 1);
			Index <= 0;
			Finish <= '0';
			state <= st_waiting;
		elsif (CE='1') then
			state <= next_state;
			TEnable <= TEnable_i;
			TReset <= TReset_i;
			TComp <= TComp_i;
			Index <= Index_i;
			Finish <= RFinish_i;
			
		end if;        
	end if;
end process;

 
OUTPUT_DECODE: process (state, TFinish, Edge, Index, index_inc)
begin
	case (state) is
		when st_waiting =>
			if Edge ='1'  then
				TEnable_i<='1';
				TReset_i <= '1';
				TComp_i <= '0'& Comp(M-1 downto 1);
				Index_i <= 0;
				RFinish_i <= '0';
			else
				TEnable_i <= '0';
				TReset_i <= '0';
				TComp_i <= '0'& Comp(M-1 downto 1);
				Index_i <= 0;
				RFinish_i <= '0';
			end if;
			
		when st_start =>
			if TFinish='1'  then
				TEnable_i<='1';
				TReset_i <= '1';
				TComp_i <= Comp;
				Index_i <= 0;
				RFinish_i <= '0';
			else
				TEnable_i <= '1';
				TReset_i <= '0';
				TComp_i <= '0'& Comp(M-1 downto 1);
				Index_i <= 0;
				RFinish_i <= '0';
			end if;
				
		when st_recibiendo =>
			if TFinish='1' then
				TEnable_i <='1';
				TReset_i <= '1';
				TComp_i <= Comp;
				Index_i <= index_inc;
				RFinish_i <= '0';
			else
				TEnable_i <= '1';
				TReset_i <= '0';
				TComp_i <= Comp;
				Index_i <= index;
				RFinish_i <= '0';
			end if;
				
		when st_parity =>
			if  TFinish='1' then
				TEnable_i<='1';
				TReset_i<='1';
				TComp_i <= Comp(M-1 downto 0);
				Index_i <= 0;
				RFinish_i <= '0';
			else
				TEnable_i <= '1';
				TReset_i <= '0';
				TComp_i <= Comp;
				Index_i <= 0;
				RFinish_i <= '0';
				
			end if;
			
		when st_stop =>
			if  TFinish='1' then
				TEnable_i<='0';
				TReset_i<='1';
				TComp_i <= '0'& Comp(M-1 downto 1);
				Index_i <= 0;
				RFinish_i <= '1';
			else
				TEnable_i <= '1';
				TReset_i <= '0';
				TComp_i <= Comp;
				Index_i <= 0;
				RFinish_i <= '0';
				
			end if;
					
					
		
		when others =>
			TEnable_i <= '0';
			TReset_i <= '0';
			TComp_i <= '0'& Comp(M-1 downto 1);
			Index_i <= 0;
			
	end case;      
end process;



NEXT_STATE_DECODE: process (state, Edge, TFinish,index)
begin
	next_state <= state;
	case (state) is
		when st_waiting =>
			if (Edge = '1') then
				next_state <= st_start;
			end if;
		when st_start =>
			if (TFinish = '1') then
				next_state <= st_recibiendo;
			end if;
		when st_recibiendo =>
			if (TFinish = '1') then
				if (index = N-1) then
					next_state <= st_parity;
				end if;
			end if;
			
		when st_parity =>
			if (TFinish = '1') then
				next_state <= st_stop;
			end if;
		
		when st_stop =>
			if (TFinish = '1') then
				next_state <= st_waiting;
			end if;
					
		when others =>
			next_state <= st_waiting;
	end case;      
end process;

process (Clk)
begin
	if (rising_edge(clk)) then
		if (Rst = '1') then
			receive <= (others =>'0');
		elsif (CE = '1') then 
			if (state = st_recibiendo) then
				if (TFinish = '1') then
					receive <= receive_tmp;
				end if;
			end if;
		end if;
	end if;
end process;

process (Clk)
begin
	if (rising_edge (clk))then
		if (Rst = '1') then
			parity <= '0';
		elsif (CE = '1') then
			if (Edge = '1') then
				parity <= '0';
			elsif (state = st_parity) then 
				if (TFinish = '1') then
					parity <= Sync_in;
				end if;
			end if;
		end if;
	end if;
end process;


receive_tmp <= Sync_in & receive(N-1 downto 1);
output <= receive;

EDGE_SIGNAL: EdgeDetector port map (
				i => Sync_in,
				q => Edge,
				rst => Rst,
				clk => Clk,
				CE =>CE
			);

SYNC_SIGNAL: sync port map (
			meta_data => input,
			sync_data => Sync_in,
			clk => Clk,
			rst => Rst
			);		
			
TIMER: Counter generic map( N => M )
		port map(
			Finish => TFinish,
			Enable => TEnable,
			Rst => TReset,
			Cmp => TComp,
			Clk => Clk,
			CE =>CE
			);
index_inc <= index + 1;

end Behavioral;

