library ieee;
use ieee.std_logic_1164.all;

package commons is
type tda is array(0 to 4,0 to 4) of std_logic_vector(0 to 63); -- tda - two dimensional array
type oda is array(0 to 4) of std_logic_vector(0 to 63);
end commons;
