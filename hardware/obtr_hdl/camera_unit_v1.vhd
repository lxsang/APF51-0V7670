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
	wr 		  : in std_logic;
    ack		  : out std_logic;
	--filter	  : in std_logic;
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
	OV7670_XCLK  	: out   STD_LOGIC;
	-- object position goes here
	sum_x_out: out std_logic_vector(31 downto 0) ;
	sum_y_out: out std_logic_vector(31 downto 0) ;
	n_out: out std_logic_vector(31 downto 0) 
);

end entity;

architecture arch of camera_unit is
  	-- signals declaration here
  	constant ID: natural := 1;
	-- constant VGA_ADDR: std_logic_vector(14 downto 0 ) 	:= "100101011111111";
-- 	constant QVGA_ADDR: std_logic_vector(14 downto 0) 	:= "001001010111111";
-- 	constant QQVGA_ADDR : std_logic_vector(14 downto 0)	:= "000010010101111";
  	constant OFFSET: unsigned(15 downto 0) := X"0008";
	
  	signal mem_addr : std_logic_vector(15 downto 0);
  	signal wr_op, px_wr, ack_db, state : std_logic := '0';
  	--signal fr_din, fr_din_next: std_logic_vector(BUF_DW-1 downto 0);
	signal cam_dout: std_logic_vector(15 downto 0) ;
	signal buffer_out,filter_out, filter_out_next : std_logic_vector(15 downto 0);
	
	signal clk_45: std_logic;
	signal fr_addr: std_logic_vector(18 downto 0) ;
	signal fr_addr_map: std_logic_vector(14 downto 0) ;
	-- select the filter or not
	signal pixons: std_logic_vector(3 downto 0);
	signal filter_ready: std_logic;
	signal rez_160x120,rez_320x240: std_logic;
	signal rez_in: std_logic_vector(1 downto 0) ;
	signal frame_end, frame_end_sync: std_logic;
	signal px_cnt:std_logic_vector(1 downto 0);
begin
  ack <=  strobe and cycle and c_sel;
  state <= (ack_db or state) and (strobe and cycle and c_sel);
  ack_tick <= ack_db;
  
write_proc : process( clk,reset ) 
begin  
	if(reset = '1') then
		rez_320x240 <= '0';
		rez_160x120 <= '0';
	elsif rising_edge(clk) then
		if((strobe and cycle and wr and c_sel) = '1' ) then
			if rez_in = "01" then
				rez_160x120 <= '1';
				rez_320x240 <= '0';
			elsif rez_in = "10" then
				rez_160x120 <= '0';
				rez_320x240 <= '1';
			else
				rez_160x120 <= '0';
				rez_320x240 <= '0';
			end if;
		else 
			rez_320x240 <= rez_320x240;
			rez_160x120 <= rez_160x120;
		end if;
	end if;
end process ;
  
  sync_proc:process(clk, reset)
  begin
    if reset = '1' then
      ack_db <= '0';
      --fr_din <= (others=>'0');
	  filter_out <= (others=>'0');
	 --fr_addr_map <= (others=>'0');
    elsif rising_edge(clk) then
      --fr_din <= fr_din_next;
	  filter_out<= filter_out_next;
      ack_db <= strobe and cycle and c_sel and (not ack_db) and (not state);
	 --fr_addr_map <= fr_addr_map_next;
    end if;
  end process;
  
 mem_addr <=std_logic_vector(unsigned(addr) - OFFSET) when (strobe and cycle and c_sel) = '1'
			else (others=>'0');
rez_in <= mem_addr(2 downto 1);
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
        rez_160x120 => rez_160x120,
        rez_320x240 => rez_320x240,
	   	href  => OV7670_HREF,	-- from camera
	   	d     => OV7670_D, 		-- from camera
	   	addr  => fr_addr,  		-- to buffer address
	   	dout  => cam_dout, 		-- to buffer out
	   	we    => px_wr
	);
	
image_processing:entity work.processing_unit
  port map(
	clk=>clk,
	reset=>reset,
	px_wr=>px_wr,
	trigger=> frame_end_sync,
	addr=> fr_addr(1 downto 0),
	data_in => cam_dout,
	data_out => pixons,
	data_ok => filter_ready
  ) ;
  center_of_mass_ent: entity work.center_of_mass
  port map (
	clk=> clk,
	reset=> reset,
	rez_320x240 => rez_320x240,
	rez_160x120 => rez_160x120,
	addr_in => fr_addr_map,
	refresh => frame_end,
	din_ok => wr_op,
	pixon => filter_out_next,
	sum_x_out=> sum_x_out,
	sum_y_out => sum_y_out,
	n_out=> n_out
  ) ;
  px_cnt_proc : process( clk,reset )
  begin
  	if reset = '1' then
  		px_cnt <= (others=>'0');
  	elsif rising_edge(clk) then
  		if(filter_ready = '1') then
			px_cnt <= std_logic_vector(unsigned(px_cnt)+1);
		end if;
  	end if;
  end process ; -- px_cnt
  
  irq_sync: entity work.flag_sync
    port map(
  	clkA => OV7670_PCLK, 
	clkB => clk,
	reset=> reset,
  	flagA=>OV7670_VSYNC,
  	flagB => frame_end_sync
    ) ;
frame_irq <= frame_end_sync;
-- frame_end <= '1' when ((rez_320x240 = '1' and fr_addr_map = QVGA_ADDR)
--  						OR (rez_160x120 = '1' and fr_addr_map = QQVGA_ADDR)
-- 						OR (rez_160x120 = '0' and rez_320x240 = '0' and fr_addr_map = VGA_ADDR))
-- 					else '0';
frame_end <= '1' when fr_addr_map = "000000000000000" and wr_op = '1' else '0';
wr_op <= '1' when px_cnt  = "00" and filter_ready = '1'  else '0';-- when filter = '1' else px_wr;
filter_out_next <= pixons&filter_out(15 downto 4) when filter_ready = '1' else filter_out;	
fr_addr_map <= std_logic_vector(unsigned(fr_addr(18 downto 4)) - 1);
 -- end process;
 frame_ent: entity work.dual_port_dual_clock
    generic map(
      ADDR_WIDTH => BUF_AW,
      DATA_WIDTH => BUF_DW
      )
    port map(
    clka    => clk,
	clkb 	=> clk,
    we      => wr_op, 		
    addr_a  => fr_addr_map,--fr_addr_map, 
    addr_b  => mem_addr(BUF_AW downto 1), 	-- requested by host
    din_a   => filter_out_next,--buffer_in,--fr_din_next, 		-- stacked data from camera
    dout_a  => open,
    dout_b  => buffer_out -- to host
    );
	dout <= buffer_out;
end architecture;
