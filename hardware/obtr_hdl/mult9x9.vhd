library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity mult9x9 is port(
  clk       : in std_logic;
  reset     : in std_logic;
  start     : in std_logic;
  a_in      : in signed(8 downto 0);
  b_in      : in signed(8 downto 0);
  r         : out signed(17 downto 0);
  ready     : out std_logic
  );
end entity;
architecture arch of mult9x9 is
  constant W : integer := 9;
  constant C_W : integer := 4;
  constant C_I : unsigned(C_W-1 downto 0) := "1001";

  type state_type is (IDLE, ADDnSHIFT);
  signal state_reg,state_next: state_type;
  signal a_reg, a_next : unsigned(W-1 downto 0);
  signal n_reg, n_next : unsigned(C_W-1 downto 0);
  signal p_reg, p_next : unsigned(2*W downto 0);

  signal pu_next : unsigned(W downto 0);-- is p_next(2*W downto W);
  signal pu_reg  : unsigned(W downto 0);-- is p_reg(2*W downto W);
  signal pl_reg  : unsigned(W-1 downto 0);-- is p_reg(W-1 downto 0);
  signal ua_in,ub_in: unsigned(W-1 downto 0);
  signal rsign : std_logic;
begin

   rsign <= a_in(W-1) xor b_in(w-1);
   ua_in <= unsigned(a_in) when a_in(W-1) = '0' else unsigned(-a_in);
   ub_in <= unsigned(b_in) when b_in(W-1) = '0' else unsigned(-b_in);
   pu_reg <= p_reg(2*W downto W);
   pl_reg <= p_reg(W-1 downto 0);

  process(clk, reset)
  begin
    if reset = '1' then
      state_reg <= IDLE;
      a_reg <= (others=>'0');
      n_reg <= (others=>'0');
      p_reg <= (others=>'0');
    elsif rising_edge(clk) then
      state_reg <= state_next;
      a_reg <= a_next;
      n_reg <= n_next;
      p_reg <= p_next;
    end if;
  end process;

  -- combinational circuit
  process(start, state_reg, a_reg, n_reg, p_reg,a_in, b_in, n_next, p_next)
  begin
    state_next <= state_reg;
    a_next <= a_reg;
    n_next <= n_reg;
    p_next <= p_reg;
    ready <= '0';

    case state_reg is
      when IDLE=>
        if start = '1' then
          p_next <= "0000000000" & ub_in;
          a_next <= ua_in;
          n_next <= C_I;
          pu_next <= p_next(2*W downto W);
          state_next <= ADDnSHIFT;
        end if;
        --ready <= '1';

      when ADDnSHIFT=>
        n_next <= n_reg - 1;
        -- add if multiplier bit is 1
        if p_reg(0) = '1' then
           pu_next <= pu_reg + ("0" & a_reg);
        else
          pu_next <= pu_reg;
        end if;
        -- shift
        p_next <= "0" & pu_next & pl_reg(W-1 downto 1);
        if(n_next = "0000") then
          state_next <= IDLE;
          ready <= '1';
        end if;
    end case;
    
        
  end process;
  
  r <= signed(p_reg(2*W-1 downto 0)) when rsign = '0' else -signed(p_reg(2*W-1 downto 0));
  
end architecture;
