library ieee;
use ieee.std_logic_1164.all;


entity teta is
port();
end teta;

architecture beh of teta is

component reg
generic(
	WIDTH:integer
);
port(
input_data:in std_logic_vector(WIDTH-1 downto 0);
clk:in std_logic;
output_data:out std_logic_vector(WIDTH-1 downto 0)
);
end component;

component wereg
generic(
WIDTH:integer
)
port(
input_data:in std_logic_vector(WIDTH-1 downto 0);
clk:in std_logic;
we:in std_logic;
output_data:out std_logic_vector(WIDTH-1 downto 0)
);
end component;
signal x_addr,y_addr:std_logic_vector(2 downto 0);
signal output_mux1,output_mux2:std_logic_vector();

begin
addr:process(clk)
begin
if(rst='1') then
	y_addr<= (others=>'0');
	x_addr<= (others=>'0');
elsif(rising_edge(clk)) then
	y_addr <=  y_addr + 1;
	if(y_addr="100") then
		y_addr <=(others=>'0');
		x_addr<= x_addr + 1;
		if(x_addr="100") then
			x_addr <=(others=>'0');
		end if;
	end if;
end if;
end process;

reg1:reg generic map() port map(,clk,);
reg2:reg generic map() port map(,clk,);

end beh;
