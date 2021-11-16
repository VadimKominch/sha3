library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity teta is
port(
    read_data:in std_logic_vector(63 downto 0);
    x_addr_out:out std_logic_vector(2 downto 0);
    y_addr_out:out std_logic_vector(2 downto 0);
    clk:in std_logic;
    rst:in std_logic;
    we_out:out std_logic;
    write_data:out std_logic_vector(63 downto 0)
);
end teta;

architecture beh of teta is

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

type D_values is array (4 downto 0) of std_logic_vector(63 downto 0);

type Dout_values is array (25 downto 0) of std_logic_vector(63 downto 0);

signal Dout:Dout_values;

signal D,res:D_values;
signal xors:D_values;
signal x_addr,y_addr:std_logic_vector(2 downto 0);
signal second_round:std_logic;
signal input_arg,xor_output,reg_output,op1,op2,shifted_op2:std_logic_vector(63 downto 0);
signal we,regwe:std_logic_vector(4 downto 0);
signal we_reg,regwe_dout:std_logic_vector(24 downto 0);

begin

addr : process( clk )
begin
  if( rst = '1' ) then
    x_addr <= (others=>'0');
    y_addr <= (others=>'0');
    second_round<='1';
    we_reg<="0000000000000000000000001";
  elsif( rising_edge(clk) ) then
    we_reg <= we_reg(23 downto 0) & we_reg(24);
    y_addr <= y_addr + 1;
    if(y_addr="100") then
        x_addr <= x_addr + 1;
        y_addr <= (others=>'0');
        if(x_addr="100") then
            x_addr <= (others=>'0');
            second_round <= not second_round; 
            end if;
    end if;
  end if ;
end process ;

x_addr_out <= x_addr;
y_addr_out <= y_addr;

reg1:reg generic map(64) port map(xor_output,clk,rst,'1',reg_output);
xor_output <= reg_output xor read_data;
we<="00001" when x_addr="000" else
    "00010" when x_addr="001" else
    "00100" when x_addr="010" else
    "01000" when x_addr="011" else
    "10000" when x_addr="100" else
    "00000";
  
D1 : for i in 0 to 4 generate
    regwe(i) <= second_round and we(i);
    reg_d:reg generic map(64) port map(xors(i),clk,rst,regwe(i),D(i));
    xors(i) <= D(i) xor read_data;
end generate D1; -- identifier

Dout(0)<=read_data;
D2 : for i in 0 to 24 generate
    regwe_dout(i) <= second_round and we_reg(i);
    reg_d:reg generic map(64) port map(Dout(i),clk,'0','1',Dout(i+1));
end generate D2; -- identifier


op1<=D(4) when x_addr="000" else
    D(0) when x_addr="001" else
    D(1) when x_addr="010" else
    D(2) when x_addr="011" else
    D(3) when x_addr="100" else
    (others=>'0');
op2<=D(1) when x_addr="000" else
    D(2) when x_addr="001" else
    D(3) when x_addr="010" else
    D(4) when x_addr="011" else
    D(0) when x_addr="100" else
    (others=>'0');
shifted_op2<=op2(62 downto 0) &op2(63);
write_data <= Dout(25) xor op1 xor shifted_op2;
we_out <= not second_round;
end beh;
