library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use STD.textio.all;
use ieee.std_logic_textio.all;


entity Keccak is
  port (
    input_data:in std_logic_vector(63 downto 0);
    clk:in std_logic;
    start:in std_logic;
    rst:in std_logic;
    output_data:out std_logic_vector(63 downto 0)
  ) ;
end Keccak ;

architecture arch of Keccak is

--To DO-----
--add reciver component---

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

component teta
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

component pi
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

component i
port(
   read_data:in std_logic_vector(63 downto 0);
   ir:in std_logic_vector(4 downto 0);
   clk:in std_logic;
   rst:in std_logic;
   we_out:out std_logic;
   write_data:out std_logic_vector(63 downto 0)
);
end component;

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

component psi
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

type state is (waiting,preloading,loading,postloading,pre_teta,teta_state,post_teta_state,pre_p_state,p_state,post_p_state,pre_pi_state,pi_state,post_pi_state,pre_psi_state,psi_state,post_psi_state,pre_i_state,i_state,post_i_state,finish);
signal x_addr_p,y_addr_p:std_logic_vector(2 downto 0);
signal x_addr_pi,y_addr_pi:std_logic_vector(2 downto 0);
signal x_addr_teta,y_addr_teta:std_logic_vector(2 downto 0);
signal x_addr_psi,y_addr_psi:std_logic_vector(2 downto 0);
signal x_addr_loading,y_addr_loading:std_logic_vector(2 downto 0);
signal current:state;
signal x_addr,y_addr:std_logic_vector(2 downto 0);
signal we,we_p,we_pi,we_psi,we_teta,we_i,finished:std_logic;
signal rst_p,rst_pi,rst_psi,rst_teta,rst_i:std_logic;
signal ram_input,ram_output:std_logic_vector(63 downto 0);
signal ram_input_p,ram_input_pi,ram_input_psi,ram_input_i,ram_input_teta:std_logic_vector(63 downto 0);
signal ram_output_p,ram_output_pi,ram_output_psi,ram_output_i,ram_output_teta:std_logic_vector(63 downto 0);
signal ir:std_logic_vector(4 downto 0); -- iteration number
signal rc_counter:std_logic_vector(3 downto 0);
signal x_addr_psi_main, y_addr_psi_main: std_logic_vector(2 downto 0);


begin

process(clk)
begin
if(rst='1') then
  current<= waiting;
  ir<=(others=>'0');
  rst_p<='0';
  rst_pi<='0';
  rst_psi<='0';
  rst_teta<='0';
  rst_i<='0';
elsif(rising_edge(clk)) then
case current is
when waiting=>
  if(start='1') then
    current <= preloading;
    rc_counter<="0000";
  end if;
when preloading =>
    x_addr_loading<="000";
    y_addr_loading<="000";
  current <= loading;
when loading=>
  y_addr_loading <= y_addr_loading +1;
  if(y_addr_loading = "100") then
      x_addr_loading <= x_addr_loading +1;
      y_addr_loading <= (others=>'0');
      if(x_addr_loading = "100") then
          x_addr_loading <= (others=>'0');
          --rst_teta<='1';
          current <= postloading;
          rc_counter <= "1111"; -- error code to disable any write operations in memory    
      end if;
  end if;
when postloading =>
  current <= pre_teta;
  rst_teta <='1';
when pre_teta =>
  rc_counter <= "0001";
  rst_teta <='0';
  current <= teta_state;
when teta_state =>
  --rst_teta <='0';
  if(x_addr="100" and y_addr="100") then
    if(we='1') then
      current <= post_teta_state;
  end if;
  end if;
when post_teta_state=>
  current <= pre_p_state;
  rc_counter <= "0010";
  --current <= waiting;
  
when pre_p_state =>
  current <= p_state;
   rst_p <= '1';
 
when p_state => 
  rst_p <= '0';
    if(x_addr="001" and y_addr="001") then
    if(we='1') then
      current <= post_p_state;
  end if;
end if;
when post_p_state =>
  current <= pre_pi_state;
when pre_pi_state =>
  current <= pi_state;
  rst_pi <= '1';
  rc_counter <= "0011";
when pi_state =>
  rst_pi <='0';
  if(x_addr="001" and y_addr="100") then
    if(we='1') then
      current <= post_pi_state;
  end if;
  end if;
when post_pi_state =>
  current <= pre_psi_state;
  rst_psi <= '1';
when pre_psi_state =>
  rc_counter <= "0100";
  current <= psi_state; 
  rst_psi <= '0';
when psi_state =>
  if(x_addr="100" and y_addr="100") then
    if(we='1') then
      current <= post_psi_state;
  end if;
  end if;
when post_psi_state =>
  current <= pre_i_state;
  rst_i <= '1';
when pre_i_state =>
  rc_counter <= "0101";
  current <= i_state; 
  rst_i <= '0';
when i_state =>
    if(we='1') then
      current <= post_i_state;
  end if;
when post_i_state =>
  current <= pre_teta;
  rst_teta <='1';
  ir <= ir +1;
when others=> current <= waiting;
end case;
end if;
end process;

ram_input <=input_data when rc_counter ="0000" else
            ram_input_teta when rc_counter = "0001" else
            ram_input_p when rc_counter = "0010" else
            ram_input_pi when rc_counter = "0011" else
            ram_input_psi when rc_counter = "0100" else
            ram_input_i;
            
x_addr <=	x_addr_loading when rc_counter ="0000" else
			       x_addr_teta when rc_counter = "0001" else
            x_addr_p when rc_counter = "0010" else
            x_addr_pi when rc_counter = "0011" else
            x_addr_psi when rc_counter = "0100" else
            "000";
            
y_addr <=	y_addr_loading when rc_counter ="0000" else
			       y_addr_teta when rc_counter = "0001" else
            y_addr_p when rc_counter = "0010" else
            y_addr_pi when rc_counter = "0011" else
            y_addr_psi when rc_counter = "0100" else
            "000";
            
we<= '1' when rc_counter = "0000" else
	     we_teta when rc_counter ="0001" else
	     we_p when rc_counter ="0010" else
	     we_pi when rc_counter ="0011" else
      	we_psi when rc_counter ="0100" else
	     we_i when rc_counter = "0101" else
	     '0';
	
ram1:ram port map(clk,ram_input,x_addr,y_addr,we,ram_output);
p1:p port map(ram_output,x_addr_p,y_addr_p,clk,rst_p,we_p,ram_input_p);
psi1:psi port map(ram_output,x_addr_psi,y_addr_psi,clk,rst_psi,we_psi,ram_input_psi);
pi1:pi port map(ram_output,x_addr_pi,y_addr_pi,clk,rst_pi,we_pi,ram_input_pi);
teta1:teta port map(ram_output,x_addr_teta,y_addr_teta,clk,rst_teta,we_teta,ram_input_teta);
i1:i port map(ram_output,ir,clk,rst_i,we_i,ram_input_i);

end architecture arch; -- arch