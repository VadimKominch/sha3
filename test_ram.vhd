library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_ram is
end test_ram;

architecture dut of test_ram is

component ram
port (
clk: in std_logic;
data: in std_logic_vector (63 downto 0);
x_addr: in std_logic_vector(2 downto 0);
y_addr: in std_logic_vector(2 downto 0);
we: in std_logic;
q: out std_logic_vector (63 downto 0)
);
end component;

signal clk:std_logic:='0';
signal we:std_logic;
signal x_addr,y_addr:std_logic_vector(2 downto 0):="000";
signal data,q:std_logic_vector(63 downto 0);

begin
clk <= not clk after 10 ns;

we<='0',
'1' after 30 ns,
'0' after 50 ns;

process(clk)
  begin
  y_addr <= y_addr + 1;
  if(y_addr ="100") then
    y_addr <= (others=>'0');
    x_addr <= x_addr + 1;
    if(x_addr = "100") then
      x_addr <= "000";
    end if;
  end if;
  end process;

data <=x"ABCDABCDABCDABCD";
ram1:ram port map(clk,data,x_addr,y_addr,we,q);
end dut;
