library ieee;
use ieee.std_logic_1164.all;

entity test_keccak_buffer is
end test_keccak_buffer;

architecture beh of test_keccak_buffer is

component keccak_buffer
port(
	input:in std_logic_vector(63 downto 0);
	clk:in std_logic;
	start:in std_logic;
	keccak_finish:in std_logic;
	last:in std_logic;
	busy:out std_logic;
	output:out std_logic_vector(511 downto 0)
);
end component;

signal input:std_logic_vector(63 downto 0);
signal output:std_logic_vector(511 downto 0);

signal start,keccak_finish,last,busy:std_logic;
signal clk:std_logic:='0';

begin

clk<= not clk after 25 ns;
start <= '0',
		 '1' after 75 ns,
		 '0' after 125 ns;
keccak_finish <= '0',
				 '1' after 725 ns,
				 '0' after 775 ns;
last<= '0',
	   '1' after 75 ns,
	   '0' after 475 ns;
	   
input<= 
        x"0000000000000001"  after 125 ns,
        x"0000000000000002"  after 175 ns,
        x"0000000000000003"  after 225 ns,
        x"0000000000000004"  after 275 ns,
        x"0000000000000005"  after 325 ns,
        x"0000000000000006"  after 375 ns,
        x"0000000000000007"  after 425 ns,
        x"ABCDABCDABCDABCD"  after 475 ns;
buf1:keccak_buffer port map(input,clk,start,keccak_finish,last,busy,output);
end beh;
