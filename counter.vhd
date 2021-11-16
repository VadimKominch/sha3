library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is
    generic(
        WIDTH:integer
    );
      port(
        load_value:in std_logic_vector(WIDTH-1 downto 0);
        clk:in std_logic;
        rst:in std_logic;
        output_data:out std_logic_vector(WIDTH-1 downto 0)
      );
end counter;


architecture arch of counter is

    signal count:std_logic_vector(WIDTH-1 downto 0);

begin
    
    counter : process( clk )
    begin
      if( rst = '1' ) then
        count <= load_value;
      elsif( rising_edge(clk) ) then
        count <= count +1;
      end if ;
    end process ; -- counter
    
end arch ; -- arch