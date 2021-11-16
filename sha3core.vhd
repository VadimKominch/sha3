library ieee;
use ieee.std_logic_1164.all;

entity sha3core is
  port(
  input:in std_logic_vector(63 downto 0);
  clk:in std_logic;
  rst:in std_logic;
  hash_value:out std_logic_vector(255 downto 0);
  ready:out std_logic;
  finish:out std_logic);
end sha3core;

architecture beh of sha3core is

component Keccak

end component;

component reg
end component;



begin
  
end beh;
