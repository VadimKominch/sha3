library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pi is
  port(
    read_data:in std_logic_vector(63 downto 0);
    x_addr_out:out std_logic_vector(2 downto 0);
    y_addr_out:out std_logic_vector(2 downto 0);
    clk:in std_logic;
    rst:in std_logic;
    we_out:out std_logic;
    write_data:out std_logic_vector(63 downto 0)
  );
end pi;

architecture beh of pi is

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

type mux_out is array (4 downto 0) of std_logic_vector(63 downto 0);

type D_values is array (24 downto 0) of std_logic_vector(63 downto 0);

signal D:D_values;


signal count:std_logic_vector(7 downto 0);
signal x_addr,y_addr:std_logic_vector(2 downto 0);
signal res_j,mod5result:std_logic_vector(2 downto 0);
signal input_we:std_logic_vector(24 downto 0);
signal sum:std_logic_vector(3 downto 0);
signal we,regwe:std_logic_vector(24 downto 0);
signal res_x:std_logic_vector(63 downto 0);
signal res_y:mux_out;
signal second_round:std_logic;

begin
  x_addr_out <= mod5result;
  y_addr_out <= x_addr;
x_addr_cnt:process(clk)
begin
  if(rst='1') then
    x_addr <= (others=>'0');
    y_addr<=(others=>'0');
    we<="0000000000000000000000001";
    second_round<='1';
  elsif(rising_edge(clk)) then
    we<=we(23 downto 0) & we(24);
    x_addr <= x_addr + 1;
    if(x_addr = "100") then
      y_addr <= y_addr + 1;
      x_addr <= (others=>'0');
      if(y_addr = "100") then
        y_addr <=(others=>'0'); 
        second_round <= not second_round;  
      end if;
    end if;
  end if;
end process;


res_j <="000" when y_addr="000" else
        "011" when y_addr="001" else
        "001" when y_addr="010" else
        "100" when y_addr="011" else
        "010" when y_addr="100" else
        "000";
sum <= "0" & x_addr + res_j;

mod5result <= "000" when sum="0000" else
        "001" when sum="0001" else
        "010" when sum="0010" else
        "011" when sum="0011" else
        "100" when sum="0100" else
        "000" when sum="0101" else
        "001" when sum="0110" else
        "010" when sum="0111" else
        "011" when sum="1000" else
        "000";



D1 : for i in 0 to 24 generate
        regwe(i) <= second_round and we(i);
        reg_d:reg generic map(64) port map(read_data,clk,rst,regwe(i),D(i));
end generate D1; -- identifier


mux_y_gate:for j in 0 to 4 generate
res_y(j) <=D(5*j) when x_addr="000" else
        D(5*j+1) when x_addr="001" else
        D(5*j+2) when x_addr="010" else
        D(5*j+3) when x_addr="011" else
        D(5*j+4) when x_addr="100" else
        D(5*j);
      end generate mux_y_gate;

res_x <=res_y(0) when mod5result="000" else
      res_y(1) when mod5result="001" else
      res_y(2) when mod5result="010" else
      res_y(3) when mod5result="011" else
      res_y(4) when mod5result="100" else
      res_y(0);
write_data <= res_x;
we_out <= not second_round;
end beh;
