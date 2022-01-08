library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_keccak_par is
end test_keccak_par;

architecture beh of test_keccak_par is

component Keccak_parallel is
  port(
  input_word:in std_logic_vector(0 to 1599);
  clk:in std_logic;
  output_word:out std_logic_vector(0 to 1599));
end component;

signal input,output:std_logic_vector(0 to 1599);
signal clk:std_logic:='0';

begin
  clk <= not clk after 25 ns;
  input <=x"0600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  kec1:Keccak_parallel port map(input,clk,output);
end beh;