library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_keccak is
end test_keccak;

architecture beh of test_keccak is

component Keccak
  port (
    input_data:in std_logic_vector(63 downto 0);
    clk:in std_logic;
    start:in std_logic;
    rst:in std_logic;
    output_data:out std_logic_vector(63 downto 0)
  ) ;
end component;

signal input_word,output_word:std_logic_vector(63 downto 0);
signal start,rst:std_logic;
signal clk:std_logic:='0';

begin
clk <= not clk after 25 ns;

input_word<=x"0000000000000006" after 275 ns,
            x"0000000000000000" after 325 ns,
            x"8000000000000000" after 675 ns,
            x"0000000000000000" after 725 ns;
rst <='0',
'1' after 75 ns,
'0' after 125 ns;

start <='0',
'1' after 225 ns,
'0' after 275 ns;  

Keccak1:Keccak port map(input_word,clk,start,rst,output_word);

end beh;
