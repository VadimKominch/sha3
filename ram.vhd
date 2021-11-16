library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
port (
clk: in std_logic;
data: in std_logic_vector (63 downto 0);
x_addr: in std_logic_vector(2 downto 0);
y_addr: in std_logic_vector(2 downto 0);
we: in std_logic;
q: out std_logic_vector (63 downto 0)
);
end ram;

architecture rtl of ram is
type mem is array(0 to 4,0 to 4) of std_logic_vector(63 downto 0);
signal ram_block: mem;

begin
process (clk)
begin
if (rising_edge(clk)) then
if (we = '1') then
ram_block(to_integer(unsigned(x_addr)),to_integer(unsigned(y_addr))) <= data;
end if;

end if;
end process;
q <= ram_block(to_integer(unsigned(x_addr)),to_integer(unsigned(y_addr)));

end rtl;