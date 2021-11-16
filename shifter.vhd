library ieee;
use ieee.std_logic_1164.all;

entity shifter is
  port(
  input_word:in std_logic_vector(63 downto 0);
  shift:in std_logic_vector(7 downto 0);
  output_data:out std_logic_vector(63 downto 0)
  );
end shifter;

architecture beh of shifter is

begin
  output_data<= input_word(62 downto 0) & input_word(63) when shift="00000001" else
  input_word(61 downto 0) & input_word(63 downto 62) when shift="00000010" else
  input_word(60 downto 0) & input_word(63 downto 61) when shift="00000011" else
  input_word(59 downto 0) & input_word(63 downto 60) when shift="00000100" else
  input_word(58 downto 0) & input_word(63 downto 59) when shift="00000101" else
  input_word(57 downto 0) & input_word(63 downto 58) when shift="00000110" else
  input_word(56 downto 0) & input_word(63 downto 57) when shift="00000111" else
  input_word(55 downto 0) & input_word(63 downto 56) when shift="00001000" else
  input_word(54 downto 0) & input_word(63 downto 55) when shift="00001001" else
  input_word(53 downto 0) & input_word(63 downto 54) when shift="00001010" else
  input_word(52 downto 0) & input_word(63 downto 53) when shift="00001011" else
  input_word(51 downto 0) & input_word(63 downto 52) when shift="00001100" else
  input_word(50 downto 0) & input_word(63 downto 51) when shift="00001101" else
  input_word(49 downto 0) & input_word(63 downto 50) when shift="00001110" else
  input_word(48 downto 0) & input_word(63 downto 49) when shift="00001111" else
  input_word(47 downto 0) & input_word(63 downto 48) when shift="00010000" else
  input_word(46 downto 0) & input_word(63 downto 47) when shift="00010001" else
  input_word(45 downto 0) & input_word(63 downto 46) when shift="00010010" else
  input_word(44 downto 0) & input_word(63 downto 45) when shift="00010011" else
  input_word(43 downto 0) & input_word(63 downto 44) when shift="00010100" else
  input_word(42 downto 0) & input_word(63 downto 43) when shift="00010101" else
  input_word(41 downto 0) & input_word(63 downto 42) when shift="00010110" else
  input_word(40 downto 0) & input_word(63 downto 41) when shift="00010111" else
  input_word(39 downto 0) & input_word(63 downto 40) when shift="00011000" else
  input_word(38 downto 0) & input_word(63 downto 39) when shift="00011001" else
  input_word(37 downto 0) & input_word(63 downto 38) when shift="00011010" else
  input_word(36 downto 0) & input_word(63 downto 37) when shift="00011011" else
  input_word(35 downto 0) & input_word(63 downto 36) when shift="00011100" else
  input_word(34 downto 0) & input_word(63 downto 35) when shift="00011101" else
  input_word(33 downto 0) & input_word(63 downto 34) when shift="00011110" else
  input_word(32 downto 0) & input_word(63 downto 33) when shift="00011111" else
  input_word(31 downto 0) & input_word(63 downto 32) when shift="00100000" else
  input_word(30 downto 0) & input_word(63 downto 31) when shift="00100001" else
  input_word(29 downto 0) & input_word(63 downto 30) when shift="00100010" else
  input_word(28 downto 0) & input_word(63 downto 29) when shift="00100011" else
  input_word(27 downto 0) & input_word(63 downto 28) when shift="00100100" else
  input_word(26 downto 0) & input_word(63 downto 27) when shift="00100101" else
  input_word(25 downto 0) & input_word(63 downto 26) when shift="00100110" else
  input_word(24 downto 0) & input_word(63 downto 25) when shift="00100111" else
  input_word(23 downto 0) & input_word(63 downto 24) when shift="00101000" else
  input_word(22 downto 0) & input_word(63 downto 23) when shift="00101001" else
  input_word(21 downto 0) & input_word(63 downto 22) when shift="00101010" else
  input_word(20 downto 0) & input_word(63 downto 21) when shift="00101011" else
  input_word(19 downto 0) & input_word(63 downto 20) when shift="00101100" else
  input_word(18 downto 0) & input_word(63 downto 19) when shift="00101101" else
  input_word(17 downto 0) & input_word(63 downto 18) when shift="00101110" else
  input_word(16 downto 0) & input_word(63 downto 17) when shift="00101111" else
  input_word(15 downto 0) & input_word(63 downto 16) when shift="00110000" else
  input_word(14 downto 0) & input_word(63 downto 15) when shift="00110001" else
  input_word(13 downto 0) & input_word(63 downto 14) when shift="00110010" else
  input_word(12 downto 0) & input_word(63 downto 13) when shift="00110011" else
  input_word(11 downto 0) & input_word(63 downto 12) when shift="00110100" else
  input_word(10 downto 0) & input_word(63 downto 11) when shift="00110101" else
  input_word(9 downto 0) & input_word(63 downto 10) when shift="00110110" else
  input_word(8 downto 0) & input_word(63 downto 9) when shift="00110111" else
  input_word(7 downto 0) & input_word(63 downto 8) when shift="00111000" else
  input_word(6 downto 0) & input_word(63 downto 7) when shift="00111001" else
  input_word(5 downto 0) & input_word(63 downto 6) when shift="00111010" else
  input_word(4 downto 0) & input_word(63 downto 5) when shift="00111011" else
  input_word(3 downto 0) & input_word(63 downto 4) when shift="00111100" else
  input_word(2 downto 0) & input_word(63 downto 3) when shift="00111101" else
  input_word(1 downto 0) & input_word(63 downto 2) when shift="00111110" else
  input_word(0) & input_word(63 downto 1) when shift="00111111" else
  input_word;
end beh;