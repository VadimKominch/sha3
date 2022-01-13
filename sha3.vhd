library ieee;
use ieee.std_logic_1164.all;

entity sha3 is
  port(
  input_word:in std_logic_vector(63 downto 0);
  clk:in std_logic;
  start:in std_logic;
  rst:in std_logic;
  start_of_packet:in std_logic;
  end_of_packet:in std_logic;
  last_packet:in std_logic;
  busy:out std_logic;
  
  output_word:out std_logic_vector(255 downto 0));
end sha3;

architecture beh of sha3 is

component Keccak_parallel
  port(
	input_word:in std_logic_vector(0 to 1599);
	clk:in std_logic;
	start:in std_logic;
	finish:out std_logic;
	output_word:out std_logic_vector(0 to 1599));
end component;

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

type state is (loading,waiting,processing,finish);
signal current:state;

signal isLast:std_logic;
signal start_keccak,finish_keccak,busy_buffer:std_logic;
signal output_buffer,p_word:std_logic_vector(511 downto 0);
signal output_keccak,input_keccak,result_keccak:std_logic_vector(1599 downto 0);

begin
process(clk)
begin
if(rst='1') then
	current <= waiting;
	input_keccak <= (others=>'0');
elsif(rising_edge(clk)) then
	case current is
		when waiting=>
			if(start='1') then -- start means start of block, not reset signal 
				isLast <= last_packet;
				current <= loading;
			end if;
		when loading=>
			if(busy_buffer='1') then
				current<=processing;
				start_keccak<='1';
				input_keccak <= (output_buffer xor input_keccak(1599 downto 1088)) & input_keccak(1087 downto 0);
			end if;
		when processing => 
			if(finish_keccak='1') then
				input_keccak <= output_keccak;
				if(isLast='1') then
					current <= finish;
					result_keccak <= output_keccak;
				else
					current <= waiting;
				end if;
			end if;
		when others=> current <= waiting;
	end case;
	end if;
end process;


kec1:Keccak_parallel port map(input_keccak,clk,start,finish_keccak,output_keccak);
kec_buf1:keccak_buffer port map(input_word,clk,start,finish_keccak,last_packet,busy_buffer,output_buffer);

end beh;