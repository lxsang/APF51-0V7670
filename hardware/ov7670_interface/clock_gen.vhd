-- The MIT License (MIT)
--
-- Copyright (c) Sang LE xsang.le@gmail.com
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity clock_gen is
  port (
	clk_in:in std_logic;
	clk_45: out std_logic;
	clk_24: out std_logic
  ) ;
end clock_gen; --entity 

architecture arch of clock_gen is
	signal sig45: std_logic := '0';
	signal sig24: std_logic:= '0';
begin
	clk_45_proc : process( clk_in, sig45 )
	begin
		if rising_edge(clk_in) then
			sig45 <=  not sig45;
		end if;
	end process ; -- clk_45
	
	clk_24_proc : process( sig45, sig24)
	begin
		if rising_edge(sig45) then
			sig24 <= not sig24;
		end if;
	end process ; -- clk_24
	clk_45 <= sig45;
	clk_24 <= sig24;
end architecture ; -- arch