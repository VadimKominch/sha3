library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity psi is
  port(
    read_data:in std_logic_vector(63 downto 0);
    x_addr_out:out std_logic_vector(2 downto 0);
    y_addr_out:out std_logic_vector(2 downto 0);
    clk:in std_logic;
    rst:in std_logic;
    we_out:out std_logic;
    write_data:out std_logic_vector(63 downto 0)
  );
end psi;

architecture beh of psi is

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
signal x_addr,y_addr:std_logic_vector(2 downto 0);
signal second_round,we_shifted:std_logic;
signal we,regwe:std_logic_vector(24 downto 0);
signal op1,op2,op3,delay_read:std_logic_vector(63 downto 0);
signal res_1,res_2,res_3:mux_out;
signal op2x1,op2andop3,write_data_shifted,write_data_shifted2:std_logic_vector(63 downto 0);
signal x_shifted,y_shifted: std_logic_vector(2 downto 0);

begin
 
    x_addr_out <= y_addr when second_round='1' else x_addr;
    y_addr_out <= x_addr when second_round='1' else y_addr;
    we_out <= not second_round;
    write_data <= write_data_shifted;

    
    -- need to process one clk period delay to send to block
    buffer1:reg generic map(64) port map(read_data,clk,'0','1',delay_read);
    
    addr : process( clk,rst)
    begin
      if( rising_edge(clk) )  then
      if( rst = '1' ) then
        x_addr <= (others=>'0');
        y_addr <= (others=>'0');
        second_round<='1';
      else 
        y_addr <= y_addr + 1;
        if(y_addr="100") then
            x_addr <= x_addr + 1;
            y_addr <= (others=>'0');
            if(x_addr="100") then
                x_addr <= (others=>'0');
                second_round <= not second_round; 
                end if;
        end if;
      end if ;
    end if;
    end process ;
  we_reg_sig:process( clk,rst)
    begin
      if( rst = '1' ) then
        we<="0000000000000000000000001";
      elsif( rising_edge(clk) ) then
        we<=we(23 downto 0) & we(24);
      end if ;
    end process ;


    D1 : for i in 0 to 24 generate
    regwe(i) <= second_round and we(i);
    reg_d:reg generic map(64) port map(read_data,clk,'0',regwe(i),D(i));
end generate D1; -- identifier


mux_y_1_gate:for j in 0 to 4 generate
res_1(j) <=D(5*j) when y_addr="000" else
    D(5*j+1) when y_addr="001" else
    D(5*j+2) when y_addr="010" else
    D(5*j+3) when y_addr="011" else
    D(5*j+4) when y_addr="100" else
    D(5*j);
  end generate mux_y_1_gate;

  mux_y_2_gate:for j in 0 to 4 generate
res_2(j) <=D(5*j) when y_addr="000" else
    D(5*j+1) when y_addr="001" else
    D(5*j+2) when y_addr="010" else
    D(5*j+3) when y_addr="011" else
    D(5*j+4) when y_addr="100" else
    D(5*j);
  end generate mux_y_2_gate;

  mux_y_3_gate:for j in 0 to 4 generate
res_3(j) <=D(5*j) when y_addr="000" else
    D(5*j+1) when y_addr="001" else
    D(5*j+2) when y_addr="010" else
    D(5*j+3) when y_addr="011" else
    D(5*j+4) when y_addr="100" else
    D(5*j);
  end generate mux_y_3_gate;

  

op1 <=res_1(0) when x_addr="000" else
  res_1(1) when x_addr="001" else
  res_1(2) when x_addr="010" else
  res_1(3) when x_addr="011" else
  res_1(4) when x_addr="100" else
  res_1(0);

  op2 <=res_2(1) when x_addr="000" else
  res_2(2) when x_addr="001" else
  res_2(3) when x_addr="010" else
  res_2(4) when x_addr="011" else
  res_2(0) when x_addr="100" else
  res_2(1);

  op3 <=res_3(2) when x_addr="000" else
  res_3(3) when x_addr="001" else
  res_3(4) when x_addr="010" else
  res_3(0) when x_addr="011" else
  res_3(1) when x_addr="100" else
  res_3(2);

not_gate:for i in 0 to 63 generate
  op2x1(i) <= not op2(i);
end generate not_gate;
  
    op2andop3<= op2x1 and op3;
    write_data_shifted <= op1 xor op2andop3;
end beh;
