library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sobel is port(
  clk       : in std_logic;
  reset     : in std_logic;
  tl_px     : in std_logic_vector(7 downto 0);
  tm_px     : in std_logic_vector(7 downto 0);
  tr_px     : in std_logic_vector(7 downto 0);
  ml_px     : in std_logic_vector(7 downto 0);
  mr_px     : in std_logic_vector(7 downto 0);
  bl_px     : in std_logic_vector(7 downto 0);
  bm_px     : in std_logic_vector(7 downto 0);
  br_px     : in std_logic_vector(7 downto 0);
  start     : in std_logic;
  ready     : out std_logic;
  gradient  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture arch of sobel is
  signal gx, gx_next,gy, gy_next : signed(8 downto 0);
  signal output : signed(8 downto 0);
  signal tlr_x, tlr_x_next, mlr_x, mlr_x_next, blr_x, blr_x_next: signed(8 downto 0);
  signal tbl_y,tbl_y_next, tbm_y, tbm_y_next, tbr_y, tbr_y_next: signed(8 downto 0);
  type state_type is(IDLE, GRAD);
  signal state, state_next: state_type;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      gx <= (others=>'0');
      gy <= (others=>'0');
      tlr_x <= (others=>'0');
      mlr_x <= (others=>'0');
      blr_x <= (others => '0');
      tbl_y <= (others=>'0');
      tbm_y <= (others=>'0');
      tbr_y <= (others=>'0');
      state <= IDLE;
    elsif rising_edge(clk) then
      gx <= gx_next;
      gy <= gy_next;
      tlr_x <= tlr_x_next;
      mlr_x <= mlr_x_next;
      blr_x <= blr_x_next;
      tbl_y <= tbl_y_next;
      tbm_y <= tbm_y_next;
      tbr_y <= tbr_y_next;
      state <= state_next;
    end if;
    
  end process;
  tlr_x_next <= signed("0"&tr_px) - signed("0"&tl_px);
  mlr_x_next <= signed("0"&mr_px(6 downto 0) & "0") -
                         signed("0"&ml_px(6 downto 0) & "0");
  blr_x_next <= signed("0"&br_px) - signed("0"&bl_px);
  -- y gradien
  tbl_y_next <= signed("0"&bl_px) - signed("0"&tl_px);
  tbm_y_next <= signed("0"&bm_px(6 downto 0) & "0") -
                         signed("0"&tm_px(6 downto 0) & "0");
  tbr_y_next <= signed("0"&br_px) - signed("0"&tr_px);

  
  process(start,state,tlr_x, mlr_x, blr_x,tbl_y, tbm_y, tbr_y, gx, gy )
  begin
    state_next <= state;
    gx_next <= gx;
    gy_next <= gy;
    ready <= '0';
    case state is
      when IDLE=>
        if(start ='1') then
          state_next <= GRAD;
        end if;
      when GRAD=>
        ready <= '1';
        gx_next <= tlr_x + mlr_x + blr_x;
        gy_next <= tbl_y + tbm_y + tbr_y;
        state_next <= IDLE;
    end case;
    end process;
  

  -- the approximative gradien G = |Gx| + |Gy|
  output <= abs(gx_next) + abs(gy_next);
  gradient <= std_logic_vector(output(7 downto 0)) when output < 255
              else (others=>'1');
end architecture;
