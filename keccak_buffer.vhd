library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity keccak_buffer is
port(
input:in std_logic_vector(63 downto 0);
clk:in std_logic;
start:in std_logic;
keccak_finish:in std_logic;
last:in std_logic;
busy:out std_logic;
output:out std_logic_vector(511 downto 0)
);
end keccak_buffer;

architecture beh of keccak_buffer is

signal p_word:std_logic_vector(511 downto 0);
signal block_count:std_logic_vector(3 downto 0);
signal inner_busy:std_logic;

begin

recieve:process(clk)
begin
if(start='1') then
	block_count <= (others=>'0');
	p_word <= (others=>'0');
	busy<='0';
elsif(rising_edge(clk)) then
	
	--if we don't recieve enough words for full vector
	if block_count < "1000" then
			block_count <= block_count + 1;
			p_word <= p_word(447 downto 0) & input;
	end if;
		
	if block_count="1000" then
		if(keccak_finish='1') then
			block_count<= (others=>'0');
			busy <= '0';
		else
			busy <= '1';
			output<= p_word;
		end if;
	end if;
end if;
end process;

end beh;
