library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.commons.all;

entity Keccak_parallel is
  port(
	input_word:in std_logic_vector(0 to 1599);
	clk:in std_logic;
	start:in std_logic;
	finish:out std_logic;
	output_word:out std_logic_vector(0 to 1599));
end Keccak_parallel;

architecture beh of Keccak_parallel is

component Keccak_parallel_iteration
  port(
  initial:in tda;
  clk:in std_logic;
  num:in integer;
  output_word:out tda);
end component;

type iteration_signal is array (0 to 25) of tda;   --output signals
signal initial1,initial,output_be_array: tda;
signal outputs: iteration_signal;
signal output_state_word:std_logic_vector(0 to 1599);
signal counter:std_logic_vector(6 downto 0);    -- 72=1001000     48=0110000   if iteration lasts 3 clock cycles - 72 if 2 - 48 

begin

control_unit:process(clk)
begin
if(start='1') then
	counter <= (others=>'0');
	finish <= '0';
elsif(rising_edge(clk)) then
	if(counter="0110000") then
		finish <= '1';
	else
		counter <= counter + 1;
	end if;
end if;
end process;



--input word to state array
--also conversion from big endian notation to little endian 
init_l1:for i in 0 to 4 generate
    init_l2:for j in 0 to 4 generate
		init_z:for k in 0 to 63 generate
			initial1(i,j)(k) <= input_word(64*(5*i+j)+k);
			initial(i,j) <= initial1(i,j)(56 to 63)&initial1(i,j)(48 to 55)&initial1(i,j)(40 to 47)&initial1(i,j)(32 to 39) & initial1(i,j)(24 to 31) & initial1(i,j)(16 to 23) & initial1(i,j)(8 to 15) & initial1(i,j)(0 to 7);
		end generate init_z;
    end generate init_l2;
end generate init_l1;

outputs(0) <= initial;

keccak_gate:for it in 0 to 24 generate
	keccak:Keccak_parallel_iteration port map(outputs(it),clk,it,outputs(it+1));
end generate keccak_gate; 

--last outputs element contains all valid words for result array
-- state array to to output word
--outputs(25)
out_l1:for i in 0 to 4 generate
    out_l2:for j in 0 to 4 generate
		out_z:for k in 0 to 63 generate
			output_be_array(i,j) <= outputs(25)(i,j)(56 to 63)&outputs(25)(i,j)(48 to 55)&outputs(25)(i,j)(40 to 47)&outputs(25)(i,j)(32 to 39) & outputs(25)(i,j)(24 to 31) & outputs(25)(i,j)(16 to 23) & outputs(25)(i,j)(8 to 15) & outputs(25)(i,j)(0 to 7);
			output_state_word(64*(5*i+j)+k) <= output_be_array(i,j)(k) ;
		end generate out_z;
    end generate out_l2;
end generate out_l1;

output_word <= output_state_word;
end beh;