library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rc is
port(
	clk:in std_logic;
	reset:in std_logic;
	ready:out std_logic;
	t:in std_logic_vector(31 downto 0);
	result: out std_logic
);
end rc;
--
--if(t mod 255 == 0) return 1
--R = 10000000
--for i in range(1, t mod 255):
--	R = 0 | R
--  R[0] = R[0] xor R[8]
--  R[4] = R[4] xor R[8]
--  R[5] = R[5] xor R[8]
--  R[6] = R[6] xor R[8]
--	R = Trunc8(R)
--return R[0]
architecture beh of rc is
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

component mod255
port(
input:in std_logic_vector(31 downto 0);
output:out std_logic_vector(7 downto 0)
);
end component;

signal input_data,Rnext,outputR:std_logic_vector(7 downto 0);
signal r_temp:std_logic_vector(0 to 8);
signal count,module255T:std_logic_vector(7 downto 0); -- t mod 255 <= 254
signal R0,R1,R2,R3,R4,R5,R6,R7,R8:std_logic;

begin

counter:process(clk)
begin
if(reset = '1') then
	count <= (others=>'0');
	ready <= '0';
elsif(rising_edge(clk)) then
	if(count = module255T) then
		ready <= '1';
	else
		count <= count + 1;
	end if;
--    add module 255 operation
end if;
end process;

mod1:mod255 port map(t,module255T);

input_data <= "10000000" when reset ='1' else Rnext;
regR:reg generic map(8) port map(input_data,clk,outputR);
r_temp <= '0' & outputR;
R0 <= r_temp(0) xor r_temp(8);
R1 <= r_temp(1);
R2 <= r_temp(2);
R3 <= r_temp(3);
R4 <= r_temp(4) xor r_temp(8);
R5 <= r_temp(5) xor r_temp(8);
R6 <= r_temp(6) xor r_temp(8);
R7 <= r_temp(7);
R8 <= r_temp(8);
Rnext <= R0 & R1 & R2 & R3 & R4 & R5 & R6 & R7;
result <= R0;
end beh;