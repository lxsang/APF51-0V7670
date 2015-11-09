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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camera_unit is
  generic(
    BUF_AW  : integer := 8;
    BUF_DW  : integer := 16
    );
  port(                       
    clk       : in std_logic;
    reset	  : in std_logic;
    addr      : in std_logic_vector(15 downto 0);
    strobe	  : in std_logic;
    cycle	  : in std_logic;
    c_sel     : in std_logic; 
    ack		  : out std_logic;
	filter	  : in std_logic;
    ack_tick  : out std_logic;
    dout      : out std_logic_vector(15 downto 0);
    cfinish   : out std_logic;
	resend 	  : in std_logic ;
	frame_irq : out std_logic;
	--- CAMERA PINS GOES HERE
	OV7670_VSYNC	: in std_logic;
	OV7670_HREF		: in std_logic;
	OV7670_PCLK		: in std_logic;
	OV7670_D		: in std_logic_vector(7 downto 0);
	OV7670_SIOC  	: out   STD_LOGIC;
	OV7670_SIOD  	: inout STD_LOGIC;
	OV7670_RESET 	: out   STD_LOGIC;
	OV7670_PWDN  	: out   STD_LOGIC;
	OV7670_XCLK  	: out   STD_LOGIC
);

end entity;

architecture arch of camera_unit is
  	-- signals declaration here
  	constant ID: natural := 1;
  	constant OFFSET: unsigned(15 downto 0) := X"0008";
  	signal mem_addr : std_logic_vector(15 downto 0);
  	signal wr_op, px_wr, ack_db, state : std_logic := '0';
  	--signal fr_din, fr_din_next: std_logic_vector(BUF_DW-1 downto 0);
	signal cam_dout, filter_out, filter_out_next, buffer_in: std_logic_vector(15 downto 0) ;
	signal clk_45: std_logic;
	signal fr_addr: std_logic_vector(BUF_AW-1 downto 0) ;
	signal fr_addr_map: std_logic_vector(BUF_AW-1 downto 0) ;
	-- select the filter or not
	signal R8,R8_next,G8, G8_next,B8,B8_next, pixon : std_logic_vector(7 downto 0);
	signal filter_ready: std_logic;
begin
  ack <=  strobe and cycle and c_sel;
  state <= (ack_db or state) and (strobe and cycle and c_sel);
  ack_tick <= ack_db;
  sync_proc:process(clk, reset)
  begin
    if reset = '1' then
      ack_db <= '0';
      --fr_din <= (others=>'0');
	  filter_out <= (others=>'0');
	  R8 <= (others=>'0');
	  G8 <= (others=>'0');
	  B8 <= (others=>'0');
    elsif rising_edge(clk) then
      --fr_din <= fr_din_next;
	  filter_out<= filter_out_next;
      ack_db <= strobe and cycle and c_sel and (not ack_db) and (not state);
	  R8 <= R8_next;
	  G8 <= G8_next;
	  B8 <= B8_next;
    end if;
  end process;
  
 mem_addr <=std_logic_vector(unsigned(addr) - OFFSET) when (strobe and cycle and c_sel) = '1'
			else (others=>'0');
			
-- clock unit
clkgen_unit:entity work.clock_gen 
	port map (
		clk_in 	=> clk,
		clk_45 	=> clk_45,
		clk_24 	=> OV7670_XCLK
		) ;
-- controller unit
cam_ctrl: entity work.ov7670_controller
	port map(
		clk45   		=> clk_45,
       	resend 			=> resend, 		-- to host
	   	config_finished => cfinish, 	-- to led
       	sioc  			=> OV7670_SIOC, -- to camera
       	siod  			=> OV7670_SIOD, -- to camera
       	reset 			=> OV7670_RESET,-- to camera
       	pwdn  			=> OV7670_PWDN  -- to camera
	);
capture_unit: entity work.ov7670_capture
	port map(
		pclk  => OV7670_PCLK,
	   	vsync => OV7670_VSYNC, 	-- from camera
	   	href  => OV7670_HREF,	-- from camera
	   	d     => OV7670_D, 		-- from camera
	   	addr  => fr_addr,  		-- to buffer address
	   	dout  => cam_dout, 		-- to buffer out
	   	we    => px_wr,
		frame_irq => frame_irq
	);
	
-- add the filter
R8_next <= cam_dout(15 downto 11) & "000" when px_wr='1' else R8;
G8_next <= cam_dout(10 downto 5) & "00" when px_wr='1' else G8;
B8_next <= cam_dout(4 downto 0) & "000" when px_wr='1' else B8;

filter_unit: entity work.hsvfilter
	port map(
  		clk => clk,
		reset => reset,
		R_in => R8_next,
		G_in => G8_next,
		B_in => B8_next,
		start => px_wr,
		pixon => pixon,
		ready => filter_ready
	);
	wr_op <= (filter_ready and  fr_addr(0)) when filter = '1' else px_wr;
	filter_out_next <= pixon&filter_out(7 downto 0) when wr_op = '1' else
	filter_out(15 downto 8)& pixon when filter_ready = '1' else filter_out;
	buffer_in <= cam_dout when filter = '0' else filter_out_next;
--fr_din_next <= cam_dout&fr_din(7 downto 0)  when wr_op = '1' else
--                 fr_din(15 downto 8)&cam_dout when
--                (px_wr = '1') else fr_din;
	fr_addr_map <= '0'&fr_addr(BUF_AW-1 downto 1) when filter = '1' else fr_addr;
 -- end process;
  frame_ent: entity work.dual_port_dual_clock
    generic map(
      ADDR_WIDTH => BUF_AW,
      DATA_WIDTH => BUF_DW
      )
    port map(
    clka    => clk,-- a bit dagerous OV7670_PCLK,
	clkb 	=> clk,
    we      => wr_op, 		
    addr_a  => fr_addr_map,--fr_addr_map, 
    addr_b  => mem_addr(BUF_AW downto 1), 	-- requested by host
    din_a   => buffer_in,--fr_din_next, 		-- stacked data from camera
    dout_a  => open,
    dout_b  => dout -- to host
    );
	
end architecture;
