library ieee;
use ieee.std_logic_1164.all;

entity test_psi is
end test_psi;

architecture beh of test_psi is

component psi
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

signal clk:std_logic:='0';
signal rst,we:std_logic;
signal x_addr,y_addr:std_logic_vector(2 downto 0);
signal read_data,output_data:std_logic_vector(63 downto 0);
begin

clk <= not clk after 10 ns;
rst <= '0','1' after 10 ns,'0' after 30 ns;

read_data<=x"0000000000000007" after 30 ns,
           x"0000000000000000" after 50 ns,
           x"000000000000000c" after 70 ns,
           x"0000000060000000" after 90 ns,
           x"2000000000000000" after 110 ns,
           x"0000600000000000" after 130 ns,
           x"0000000000c00000" after 150 ns,
           x"0000000000000020" after 170 ns,
           x"0000001000000000" after 190 ns,
           x"0000000000000000" after 210 ns,
           x"0000040000000000" after 230 ns,
           x"0000000000000008" after 250 ns,
           x"0000000000000000" after 270 ns,
           x"0000000000001800" after 290 ns,
           x"0000060000000000" after 310 ns,
           x"0000000000000000" after 330 ns,
           x"0000d00000000000" after 350 ns,
           x"0000000000000c00" after 370 ns,
           x"0000000000004000" after 390 ns,
           x"0000020000000000" after 410 ns,
           x"0000000000030000" after 430 ns,
           x"1000000000000000" after 450 ns,
           x"0000000000040000" after 470 ns,
           x"0000000000000000" after 490 ns,
           x"0000000000000018" after 510 ns;
p1:psi port map(read_data,x_addr,y_addr,clk,rst,we,output_data);

end beh;
