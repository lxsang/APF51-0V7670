library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity center_of_mass is
  port (
	clk,reset:in std_logic;
	addr_out : out std_logic_vector(14 downto 0) ;
	din: in std_logic_vector(15 downto 0) ;-- 2 black pixel
  ) ;
end center_of_mass; --entity 

architecture arch of center_of_mass is

begin

end architecture ; -- arch