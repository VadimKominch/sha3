library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity i is
  port(
    read_data:in std_logic_vector(63 downto 0);
    ir:in std_logic_vector(4 downto 0);
    clk:in std_logic;
    rst:in std_logic;
    we_out:out std_logic;
    write_data:out std_logic_vector(63 downto 0)
  );
end i;

architecture beh of i is

component reg
generic(
    WIDTH:integer
);
port(
input_data:in std_logic_vector(WIDTH-1 downto 0);
clk:in std_logic;
rst:in std_logic;
we:in std_logic;
output_data:out std_logic_vector(WIDTH-1 downto 0)
);
end component;

signal count:std_logic_vector(1 downto 0);
signal write_data1:std_logic_vector(63 downto 0);
type memory is array ( 0 to 23 ) of std_logic_vector( 63 downto 0 ) ;
constant myrom : memory := (
0=>x"0000000000000001",
1=>x"0000000000008082",
2=>x"800000000000808A",
3=>x"8000000080008000",
4=>x"000000000000808B",
5=>x"0000000080000001",
6=>x"8000000080008081",
7=>x"8000000000008009",
8=>x"000000000000008A",
9=>x"0000000000000088",
10=>x"0000000080008009",
11=>x"000000008000000A",
12=>x"000000008000808B",
13=>x"800000000000008B",
14=>x"8000000000008089",
15=>x"8000000000008003",
16=>x"8000000000008002",
17=>x"8000000000000080",
18=>x"000000000000800A",
19=>x"800000008000000A",
20=>x"8000000080008081",
21=>x"8000000000008080",
22=>x"0000000080000001",
23=>x"8000000080008008");
signal shifted,rc_constant:std_logic_vector(63 downto 0);

begin
  
reg1:reg generic map(64) port map(read_data,clk,'0','1',shifted);
reg2:reg generic map(64) port map(write_data1,clk,'0','1',write_data);
  process(clk)
    begin
      if(clk='1' and clk'event) then
    rc_constant <= myrom(to_integer(unsigned(ir)));
  end if;
  end process;
  we:process(clk,rst)
  begin
    if(rst='1') then
      count<=(others=>'0');
    elsif(rising_edge(clk)) then
      count <= count +1;
  end if;
  end process;
  write_data1<= shifted xor rc_constant;
  we_out <= '1' when count ="10" else '0';
end beh;