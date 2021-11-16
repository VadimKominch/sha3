library ieee;
use ieee.std_logic_1164.all;

entity test_i is
end test_i;

architecture beh of test_i is

component i
port(
   read_data:in std_logic_vector(63 downto 0);
   ir:in std_logic_vector(4 downto 0);
   clk:in std_logic;
   rst:in std_logic;
   we_out:out std_logic;
   write_data:out std_logic_vector(63 downto 0)
);
end component;

signal ir:std_logic_vector(4 downto 0);
signal read_data,write_data:std_logic_vector(63 downto 0);
signal we,rst:std_logic;
signal clk:std_logic:='0';

begin
  clk <= not clk after 10 ns;
rst <= '0','1' after 10 ns,'0' after 30 ns;

read_data<=x"0000040000000007" after 30 ns;
             
ir<="00000";
  i1:i port map(read_data,ir,clk,rst,we,write_data);
end beh;