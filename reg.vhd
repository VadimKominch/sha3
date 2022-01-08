library ieee;
use ieee.std_logic_1164.all;

entity reg is
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
end reg;

architecture beh of reg is


begin
process(clk,rst)
  begin
    if(rst='1') then
        output_data<= (others=>'0');
    elsif(rising_edge(clk)) then
        if(we='1') then
            output_data<= input_data;
        end if;
    end if;
end process;
end beh;
