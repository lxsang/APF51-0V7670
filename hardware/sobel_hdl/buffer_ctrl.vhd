-- This is the memory buffer controller
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buffer_ctrl is
  generic(
    IMG_W   : integer := 4;
    IMG_H   : integer := 4;
    BUF_AW  : integer := 8;
    BUF_DW  : integer := 16
    );
  port(                       
    clk       : in std_logic;
    --start     : in std_logic;
    reset	  : in std_logic;
    din		  : in std_logic_vector(15 downto 0);
    addr      : in std_logic_vector(15 downto 0);
    strobe	  : in std_logic;
    cycle	  : in std_logic;
    c_sel     : in std_logic; 
    ack		  : out std_logic;
    ack_tick  : out std_logic;
    wr		  : in std_logic;
    dout      : out std_logic_vector(15 downto 0);
    finish    : out std_logic
);

end entity;

architecture arch of buffer_ctrl is
  -- signals declaration here
  constant ID: natural := 1;
  constant OFFSET: unsigned(15 downto 0) := X"0008";
  signal mem_addr : std_logic_vector(15 downto 0);
  signal wr_op, ack_db, state, dst_wr : std_logic := '0';
  signal dout_b, dst_din, dst_din_next: std_logic_vector(BUF_DW-1 downto 0);
  signal filter_din, filter_dout : std_logic_vector(7 downto 0);
  signal src_addr_map,src_addr, src_addr_next,dst_addr, dst_addr_map: std_logic_vector(BUF_AW-1 downto 0);
  signal dst_we, sobel_start: std_logic;
-- signal str_addr : std_logic_vector(15 downto 0);
--  signal test_addr: std_logic_vector(7 downto 0);
begin
  wr_op <= strobe and cycle and c_sel and wr;
  ack <=  strobe and cycle and c_sel;
  state <= (ack_db or state) and (strobe and cycle and c_sel);
  ack_tick <= ack_db;
  sync_proc:process(clk, reset)
  begin
    if reset = '1' then
      ack_db <= '0';
      src_addr <= (others=>'0');
      dst_din <= (others=>'0');
    elsif rising_edge(clk) then
      src_addr <= src_addr_next;
      dst_din <= dst_din_next;
      ack_db <= strobe and cycle and c_sel and (not ack_db) and (not state);
    end if;
  end process;
  
 mem_addr <=std_logic_vector(unsigned(addr) - OFFSET) when (strobe and cycle and c_sel) = '1' else (others=>'0');
 -- end process;
  --str_addr <= "0000000"& addr & "0";
  src_frame_ent: entity work.frame
    generic map(
      ADDR_WIDTH => BUF_AW,
      DATA_WIDTH => BUF_DW
      )
    port map(
    clk     => clk,
    we      => wr_op,
    addr_a  => mem_addr(BUF_AW downto 1), -- 7 downto 1 for real
    addr_b  => src_addr_map,
    din_a   => din,
    dout_a  => open,
    dout_b  => dout_b
    );
  -- FIX-ME : hardcode the data length 
  filter_din <= dout_b(15 downto 8) when src_addr(0) = '1'
                else dout_b(7 downto 0);
  src_addr_map <= "0" & src_addr_next(BUF_AW-1 downto 1);
  --dst_addr_map <= "0"
  dst_we <= '1' when (dst_wr and  dst_addr(0)) = '1' else '0';
  dst_din_next <= filter_dout&dst_din(7 downto 0)  when
                  (dst_wr and dst_addr(0)) = '1' else
                   dst_din(15 downto 8)&filter_dout when
                  (dst_wr = '1') else dst_din;
  dst_addr_map <= "0" & dst_addr(BUF_AW-1 downto 1);
  -- sobel filter
  sobel_start <= '1' when (unsigned(mem_addr) = IMG_W) and wr_op = '1'
                 else '0';
  sobel_fltr_ent: entity work.filter
    generic map(
      AW => BUF_AW,
      IMG_W => IMG_W,
      IMG_H => IMG_H
      )
    port map(
    clk     => clk,
    reset   => reset,
    start   => sobel_start,
    finish  => finish,
    src_addr=> src_addr_next,
    dst_addr=> dst_addr,
    data_in => filter_din,
    data_out=> filter_dout,
    wr_out  => dst_wr);

  --test_addr <= "0"&dst_addr(7 downto 1);
    dst_ent: entity work.frame
    generic map(
      ADDR_WIDTH => BUF_AW,
      DATA_WIDTH => BUF_DW
      )
      port map(
      clk    => clk,
      we     => dst_we,
      addr_a => dst_addr_map,
      addr_b  => mem_addr(BUF_AW downto 1), --14 downto 1
      din_a   => dst_din_next,
      dout_a  => open,
      dout_b  => dout
      );
  --dout <= dout_b;
end architecture;
