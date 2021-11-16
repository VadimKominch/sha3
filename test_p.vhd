library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity test_p is
end test_p;

architecture beh of test_p is

component p
port(
    read_data:in std_logic_vector(63 downto 0);
    x_addr_out:out std_logic_vector(2 downto 0);
    y_addr_out:out std_logic_vector(2 downto 0);
    clk:in std_logic;
    rst:in std_logic;
    we_out:out std_logic;
    write_data:out std_logic_vector(63 downto 0)
);
end component;


signal read_data,write_data:std_logic_vector(63 downto 0);
signal we,rst:std_logic;
signal clk:std_logic:='0';
signal x_addr,y_addr:std_logic_vector(2 downto 0);
file file_RESULTS : text;

begin
  
clk <= not clk after 10 ns;
rst <= '0','1' after 10 ns,'0' after 30 ns;

read_data<=x"0000000000000007" after 10 ns,
           x"0000000000000006" after 30 ns,
           x"0000000000000001" after 50 ns,
           x"8000000000000000" after 70 ns,
           x"0000000000000006" after 90 ns,
           x"8000000000000000" after 110 ns,
           x"0000000000000000" after 130 ns,
           x"0000000000000001" after 170 ns,
           x"8000000000000006" after 190 ns,
           x"0000000000000000" after 210 ns,
           x"0000000000000006" after 230 ns,
           x"000000000000000c" after 250 ns,
           x"0000000000000001" after 290 ns,
           x"0000000000000000" after 310 ns,
           x"000000000000000c" after 330 ns,
           x"0000000000000000" after 350 ns,
           x"8000000000000000" after 370 ns,
           x"0000000000000001" after 410 ns,
           x"000000000000000c" after 430 ns,
           x"8000000000000000" after 450 ns,
           x"000000000000000c" after 470 ns,
           x"0000000000000006" after 490 ns;
p1:p port map(read_data,x_addr,y_addr,clk,rst,we,write_data);


process(clk)
    variable v_OLINE     : line;
   variable v_SPACE     : character:=' ';
     
  begin
 
    file_open(file_RESULTS, "output_results.txt", append_mode);
 
    if(rising_edge(clk)) then
    if(we='1') then
 
      --write(v_OLINE, to_hex_string(write_data), right, 16);
      write(v_OLINE , x_addr, right,3);
      write(v_OLINE, v_SPACE,right,1);
      write(v_OLINE , y_addr, right,3);
      write(v_OLINE, v_SPACE,right,1);
      hwrite(v_OLINE,write_data);
      writeline(file_RESULTS, v_OLINE);
    end if;
 end if;
    file_close(file_RESULTS);
  end process;

end beh;