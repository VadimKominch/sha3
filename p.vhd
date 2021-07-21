library ieee;
use ieee.std_logic_1164.all;

entity p is
port(
clk:in std_logic;
rst:in std_logic;
output_data:out std_logic
);
end p;

architecture beh of p is
signal x_addr,y_addr:std_logic_vector(2 downto 0);

begin
x_counter:process(clk)
begin
if(rst='1') then
	x_addr <="001";
	y_addr <="000";
elsif(rising_edge(clk)) then
	x_addr<=y_addr;
	y_addr <= (2*x_addr+3*y_addr) mod 5;
end if;
end process;

end beh;
