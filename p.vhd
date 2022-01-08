library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity p is
port(
    read_data:in std_logic_vector(63 downto 0);
    x_addr_out:out std_logic_vector(2 downto 0);
    y_addr_out:out std_logic_vector(2 downto 0);
    clk:in std_logic;
    rst:in std_logic;
    we_out:out std_logic;
    write_data:out std_logic_vector(63 downto 0)
);
end p;

architecture beh of p is

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

component shifter
  port(
  input_word:in std_logic_vector(63 downto 0);
  shift:in std_logic_vector(7 downto 0);
  output_data:out std_logic_vector(63 downto 0)
  );
end component;

type Dout_values is array (25 downto 0) of std_logic_vector(63 downto 0);
type addr_values is array (25 downto 0) of std_logic_vector(2 downto 0);

signal DaddrX,DaddrY:addr_values;
signal Dout:Dout_values;

signal count,scaler:std_logic_vector(5 downto 0);
signal shift_t:std_logic_vector(5 downto 0);
signal mod5result:std_logic_vector(2 downto 0);
signal res_i,res_j:std_logic_vector(2 downto 0);
signal x_mux_out,y_mux_out:std_logic_vector(2 downto 0);
signal reg_x_out,reg_y_out:std_logic_vector(2 downto 0);
signal sum:std_logic_vector(3 downto 0);
signal input_shift:std_logic_vector(7 downto 0);
signal shifted_result,result:std_logic_vector(63 downto 0);
signal second_round:std_logic;
signal x_addr,y_addr:std_logic_vector(2 downto 0);
signal isworked:std_logic; -- logic one if block is working now otherwise undefined or zero

begin
    we_out <= second_round;
counter_prescaler:process(clk,rst)
begin
if(rst='1') then
  count <= "000010";
  second_round <= '0';
  isworked <= '1';
elsif(rising_edge(clk)) then	  
	count <= count + 1;     -- t is [0;23] 24 word change
	if(count = "011000") then  -- 24 T clock to reset
	  second_round <= '1';
	  end if;
	if(count = "110000") then
	  second_round <='0';
	  isworked <='0';
	  end if;
end if;
end process;

counter_next_number:process(clk,rst)
begin
if(rst='1') then
  scaler <= "000010";
  shift_t <= "000001";
elsif(rising_edge(clk)) then
  if(second_round='1') then
	shift_t<=shift_t + scaler;
	scaler <= scaler + 1;
	end if;
end if;
end process;

x_mux_out<="001" when rst='1' else reg_y_out;
y_mux_out<="000" when rst='1' else mod5result;

reg_x:reg generic map(3) port map(x_mux_out,clk,'0','1',reg_x_out);
reg_y:reg generic map(3) port map(y_mux_out,clk,'0','1',reg_y_out);

res_i <="000" when reg_x_out="000" else
        "010" when reg_x_out="001" else
        "100" when reg_x_out="010" else
        "001" when reg_x_out="011" else
        "011" when reg_x_out="100" else
        "000";

res_j <="000" when reg_y_out="000" else
        "011" when reg_y_out="001" else
        "001" when reg_y_out="010" else
        "100" when reg_y_out="011" else
        "010" when reg_y_out="100" else
        "000";
sum <= "0" & res_i + res_j;
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

input_shift<= "00" & shift_t;  
shifter1:shifter port map(Dout(24),input_shift,result);

--Dout(0)<=result;
Dout(0) <=read_data;
Dvalues : for i in 0 to 24 generate
    reg_d:reg generic map(64) port map(Dout(i),clk,'0',isworked,Dout(i+1));
end generate Dvalues; -- identifier

--DaddrX(0)<=reg_x_out;
DaddrX(0)<=x_mux_out;
DaddrXout : for i in 0 to 24 generate
    reg_x:reg generic map(3) port map(DaddrX(i),clk,'0',isworked,DaddrX(i+1));
end generate DaddrXout; -- identifier

--DaddrY(0)<=reg_y_out;
DaddrY(0)<=y_mux_out;
DaddrYout : for i in 0 to 24 generate
    reg_y:reg generic map(3) port map(DaddrY(i),clk,'0',isworked,DaddrY(i+1));
end generate DaddrYout; -- identifier

--write_data <= Dout(24);
write_data <=result;
x_addr_out <= x_mux_out when second_round='0' else DaddrX(24);  
y_addr_out <= y_mux_out when second_round='0' else DaddrY(24);
end beh;
