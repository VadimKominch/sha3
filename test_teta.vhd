library ieee;
use ieee.std_logic_1164.all;


entity test_teta is
end test_teta;


architecture beh of test_teta is

type mem is array(0 to 24) of std_logic_vector(63 downto 0);
signal ram_block: mem;

component teta
  port( 
    read_data:in std_logic_vector(63 downto 0);
    x_addr_out:out std_logic_vector(2 downto 0);
    y_addr_out:out std_logic_vector(2 downto 0);
    clk:in std_logic;
    rst:in std_logic;
    we_out:out std_logic;
    write_data:out std_logic_vector(63 downto 0)
);
end component;

signal read_data,write_data:std_logic_vector(63 downto 0);
signal we,rst:std_logic;
signal clk:std_logic:='0';
signal x_addr,y_addr:std_logic_vector(2 downto 0);
begin
  
clk <= not clk after 10 ns;
rst <= '0','1' after 10 ns,'0' after 30 ns;

read_data<=x"0000000000000006" after 10 ns,
           x"0000000000000000" after 30 ns,
           x"8000000000000000" after 170 ns,
           x"0000000000000000" after 190 ns;
teta1:teta port map(read_data,x_addr,y_addr,clk,rst,we,write_data);
end beh;
