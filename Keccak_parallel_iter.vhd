library ieee;
use ieee.std_logic_1164.all;
use work.commons.all;

entity Keccak_parallel_iteration is
  port(
  initial:in tda;
  clk:in std_logic;
  num:in integer;
  output_word:out tda);
end Keccak_parallel_iteration;

architecture beh of Keccak_parallel_iteration is

type rc_constants is array(0 to 23) of std_logic_vector(0 to 63);
type p_subtype is array(0 to 24) of std_logic_vector(0 to 63);
type p_constants is array (0 to 4,0 to 4) of integer; 
signal after_teta,after_p,after_p_reg,negative_words,after_pi,after_psi,after_i: tda;
signal c,d: oda;
signal shifts:p_constants:=(( 0,  1, 62, 28, 27),
                            (36, 44,  6, 55, 20),
                            ( 3, 10, 43, 25, 39),
                            (41, 45, 15, 21,  8),
                            (18,  2, 61, 56, 14));
 signal pi_indexes:p_constants:=((0, 3, 1, 4, 2),
                              (1, 4, 2, 0, 3),
                              (2, 0, 3, 1, 4),
                              (3, 1, 4, 2, 0),
                              (4, 2, 0, 3, 1));                         
signal RC:rc_constants:=(
                        x"0000000000000001",
                        x"0000000000008082",
                        x"800000000000808A",
                        x"8000000080008000",
                        x"000000000000808B",
                        x"0000000080000001",
                        x"8000000080008081",
                        x"8000000000008009",
                        x"000000000000008A",
                        x"0000000000000088",
                        x"0000000080008009",
                        x"000000008000000A",
                        x"000000008000808B",
                        x"800000000000008B",
                        x"8000000000008089",
                        x"8000000000008003",
                        x"8000000000008002",
                        x"8000000000000080",
                        x"000000000000800A",
                        x"800000008000000A",
                        x"8000000080008081",
                        x"8000000000008080",
                        x"0000000080000001",
                        x"8000000080008008");
signal pi_words:p_subtype;

component reg is
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


begin
-- generate state array from 1600-bit vector and convert it endianness


--TETA
c1:for i in 0 to 4 generate
    c(i) <= initial(0,i) xor initial(1,i) xor initial(2,i) xor initial(3,i) xor initial(4,i);
end generate c1;

d1:for i in 0 to 4 generate
  d(i) <= c((i-1) mod 5) xor (c((i+1) rem 5)(1 to 63)&c((i+1) rem 5)(0) );
end generate d1;


outer_teta_1:for i in 0 to 4 generate
    outer_teta_2:for j in 0 to 4 generate
        after_teta(i,j) <= initial(i,j) xor d(j);
    end generate outer_teta_2;
end generate outer_teta_1;

--P
x_loop:for i in 0 to 4 generate
    y_loop:for j in 0 to 4 generate
    --set x and y as vars and change them every cycle to build
    -- (t+1)*(t+2)/2 --shift right
            reg1:reg generic map(64) port map(after_p(i,j),clk,'0','1',after_p_reg(i,j));
            after_p(i,j) <= after_teta(i,j)(shifts(i,j) to 63)&after_teta(i,j)(0 to shifts(i,j)-1);
            end generate y_loop;
end generate x_loop;
--PI
x_loop_pi:for i in 0 to 4 generate
    y_loop_pi:for j in 0 to 4 generate
            --assert pi_indexes(i,j) /= ((i+3*j) mod 5) report "("&integer'image(i)&" " & integer'image(j)&") ("&integer'image(((i+3*j) mod 5))&" "&integer'image(i)&")";

            after_pi(j,i) <= after_p_reg(i,pi_indexes(i,j));
            end generate y_loop_pi;
end generate x_loop_pi;
--PSI
x_loop_psi:for i in 0 to 4 generate
    y_loop_psi:for j in 0 to 4 generate
        negative_words(j,i) <= not after_pi(j,(i+1) rem 5);
        after_psi(j,i) <= after_pi(j,i) xor (negative_words(j,i) and after_pi(j,(i+2) rem 5));
    end generate y_loop_psi;
end generate x_loop_psi;
--I
x_loop_i:for i in 0 to 4 generate
    y_loop_i:for j in 0 to 4 generate
        first:if i = 0 and j = 0 generate
            after_i(i,j) <= after_psi(i,j) xor RC(num);
        end generate first;
        second:if not((i = 0) and (j = 0)) generate
            after_i(i,j) <= after_psi(i,j);
        end generate second;
    end generate y_loop_i;
end generate x_loop_i;

output_word <= after_i;

end beh;