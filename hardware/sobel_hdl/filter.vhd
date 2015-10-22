library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter is
  generic(
    AW      : integer := 8;
    IMG_W   : integer := 4;
    IMG_H   : integer := 4
    );
  port(
    clk       : in std_logic;
    reset     : in std_logic;
    start     : in std_logic;
    finish    : out std_logic;
    src_addr  : out std_logic_vector(AW-1 downto 0);
    dst_addr  : out std_logic_vector(AW-1 downto 0);
    data_in   : in std_logic_vector(7 downto 0);
    data_out  : out std_logic_vector(7 downto 0);
    wr_out    : out std_logic
    );
end entity;

architecture arch of filter is
  type state_type is (IDLE, TL, TM, TR, ML, MR,BL,BM, BR, SOBEL);
  signal x, x_next : unsigned(AW-1 downto 0);
  signal y, y_next : unsigned(AW-1 downto 0);
  signal tl_px, tl_px_next, tm_px, tm_px_next, tr_px, tr_px_next,ml_px, ml_px_next, mr_px, mr_px_next, bl_px, bl_px_next, bm_px, bm_px_next, br_px, br_px_next : std_logic_vector(7 downto 0);
  signal previous_line, previous_line_next, current_line, current_line_next, next_line, next_line_next: unsigned(AW-1 downto 0) := (others=>'0');
  signal state, state_next: state_type;
  signal src_addr_reg, src_addr_next, dst_addr_reg, dst_addr_next: std_logic_vector(AW-1 downto 0);
  signal sobel_start: std_logic;
begin
  src_addr <= src_addr_next;
  dst_addr <= dst_addr_next;
  sobel_ent: entity work.sobel port map(
    clk      => clk,
    reset   => reset,
    tl_px     => tl_px_next,
    tm_px     => tm_px_next,
    tr_px     => tr_px_next,
    ml_px     => ml_px_next,
    mr_px     => mr_px_next,
    bl_px     => bl_px_next,
    bm_px     => bm_px_next,
    br_px     => br_px_next,
    start       => sobel_start,
    ready     => wr_out,
    gradient  => data_out
  );

  -- register change
  process(clk,reset)
  begin
    if reset = '1' then
      state <= IDLE;
      x <= (others=>'1');
      y <= (others => '1');
      previous_line <= (others=>'0');
      current_line <= (others=>'0');
      next_line <= (others=>'0');
      tl_px <= (others=>'0');
      tm_px <= (others=>'0');
      tr_px <= (others=>'0');
      ml_px <= (others=>'0');
      mr_px <= (others=>'0');
      bl_px <= (others=>'0');
      bm_px <= (others=>'0');
      br_px <= (others=>'0');
      src_addr_reg <= (others=>'0');
      dst_addr_reg <= (others=>'0');
    elsif rising_edge(clk) then
      state <= state_next;
      x <= x_next;
      y <= y_next;
      previous_line<= previous_line_next;
      current_line<= current_line_next;
      next_line<= next_line_next;
      tl_px <= tl_px_next;
      tm_px <= tm_px_next;
      tr_px <= tr_px_next;
      ml_px <= ml_px_next;
      mr_px <= mr_px_next;
      bl_px <= bl_px_next;
      bm_px <= bm_px_next;
      br_px <= br_px_next;
      src_addr_reg <= src_addr_next;
      dst_addr_reg <= dst_addr_next;
    end if;
    
  end process;

  -- combinational logic
  process(state,x,y,data_in, start, previous_line, current_line, next_line, tl_px, tm_px, tr_px,ml_px, mr_px, bl_px, bm_px, br_px, src_addr_reg, dst_addr_reg)
  begin
    state_next <= state;
    x_next <= x;
    y_next <= y;
    previous_line_next <= previous_line;
    current_line_next <= current_line;
    next_line_next <= next_line;
    tl_px_next <= tl_px;
    tm_px_next <= tm_px;
    tr_px_next <= tr_px;
    ml_px_next <= ml_px;
    mr_px_next <= mr_px;
    bl_px_next <= bl_px;
    bm_px_next <= bm_px;
    br_px_next <= br_px;
    --wr_out <= '0';
    sobel_start <= '0';
    finish <= '0';
    src_addr_next <= src_addr_reg;
    dst_addr_next <= dst_addr_reg;
    case state is
      when IDLE=>
        if(start = '1') then
          tl_px_next <= (others=>'0');
          tm_px_next <= (others=>'0');
          tr_px_next <= (others=>'0');
          ml_px_next <= (others=>'0');
          mr_px_next <= (others=>'0');
          bl_px_next <= (others=>'0');
          bm_px_next <= (others=>'0');
          br_px_next <= (others=>'0');
          x_next <= (others=>'0');
          y_next <= (others=>'0');
          --finish <= '0';
          previous_line_next <= (others=>'0');
          current_line_next <= (others=>'0');
          next_line_next <= to_unsigned(IMG_W, AW);
          state_next <= TL;
          src_addr_next<= (others=>'0');
        elsif x < IMG_H then
          --finish <= '0';
          state_next <= TL;
          if y = 0 then
            previous_line_next <= current_line;
            current_line_next <= next_line;
            next_line_next <= next_line + IMG_W;
          end if;
        elsif x = IMG_H then
          x_next <= (others=>'1');
          finish <= '1';
        end if;

      when TL=>
        if x /= 0 and y /= 0 then
          src_addr_next <= std_logic_vector(previous_line + y - 1);
        end if;
        state_next<= TM;

      when TM=>
        if x = 0 or y = 0 then
          tl_px_next <= (others=>'0');
        else
          tl_px_next <= data_in;
        end if;
        -- for tm
        if  x /= 0 then
          src_addr_next <= std_logic_vector(previous_line + y);
        end if;
        state_next <= TR;

      when TR=>
        if(x = 0) then
          tm_px_next <= (others=>'0');
        else
          tm_px_next <= data_in;
        end if;
        -- for tr px
        if x /= 0 and y /= IMG_W -1 then
          src_addr_next <= std_logic_vector(previous_line + y + 1);
        end if;
        state_next <= ML;

      when ML=>
        if x = 0 or y = IMG_W -1 then
          tr_px_next <= (others=>'0');
        else
          tr_px_next <= data_in;
        end if;
        --for ml
        if y /= 0 then
          src_addr_next <= std_logic_vector(current_line + y - 1);
        end if;
        state_next <= MR;

      when MR=>
        if y = 0 then
          ml_px_next <= (others=>'0');
        else
          ml_px_next <= data_in;
        end if;
        -- for mr
        if y /= IMG_W - 1 then
          src_addr_next <= std_logic_vector(current_line + y + 1);
        end if;
        state_next <= BL;

      when BL =>
        if y = IMG_W - 1 then
          mr_px_next <= (others => '0');
        else
          mr_px_next <= data_in;
        end if;
        -- for bl
        if y /= 0 and x /= IMG_H - 1 then
          src_addr_next <= std_logic_vector(next_line + y -1);
        end if;
        state_next <= BM;

      when BM=>
        if y = 0 or x = IMG_H -1 then
          bl_px_next <= (others=>'0');
        else
          bl_px_next <= data_in;
        end if;
        -- for bm
        if x/= IMG_H -1 then
          src_addr_next <= std_logic_vector(next_line + y);
        end if;
        state_next <= BR;

      when BR=>
        if x = IMG_H - 1 then
          bm_px_next <= (others=>'0');
        else
          bm_px_next <= data_in;
        end if;
        -- for br
        if x /= IMG_H - 1 and y /= IMG_W - 1 then
          src_addr_next <= std_logic_vector(next_line + y + 1);
        end if;
        state_next <= SOBEL;

      when SOBEL =>
        if x = IMG_H - 1 or y = IMG_W - 1 then
          br_px_next <= (others=>'0');
        else
          br_px_next <= data_in;
        end if;
        -- sobel calculation 1 clock
        dst_addr_next <= std_logic_vector(current_line+y);
        sobel_start <= '1';
        if y = IMG_W - 1 then
          x_next <= x + 1;
          y_next <= (others=>'0');
        else
          y_next <= y + 1;
        end if;
        state_next <= IDLE;

      --when WR=>
        -- write to output buffer
        --wr_out <= '1';
        
    end case;
    
  end process;
  
end architecture;
