library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sqrt is port(
  clk       : in std_logic;
  reset     : in std_logic;
  din_valid : in std_logic;
  din       : in std_logic_vector(15 downto 0);
  dout_ready: out std_logic;
  dout      : out std_logic_vector(7 downto 0)
  );
end entity;


architecture arch of sqrt is
  type state_type is (IDLE, PART1, PART2);
  signal state, state_next: state_type;
  signal mask, mask_next : unsigned(15 downto 0) := X"4000";
  signal root, root_next, remainder, remainder_next: unsigned(15 downto 0);
begin
  --
  process(clk, reset)
  begin
    if reset = '1' then
      state<= IDLE;
      mask <= X"4000";
      root <= (others=>'0');
      remainder <= (others=>'0');
    elsif rising_edge(clk) then
      state <= state_next;
      mask <= mask_next;
      root <= root_next;
      remainder <= remainder_next;
    end if;
    
  end process;

  process(state,din, din_valid, mask, root, remainder)
  begin
    state_next <= state;
    mask_next <= mask;
    remainder_next <= remainder;
    root_next <= root;
    dout_ready <= '0';
    case state is
      when IDLE=>
        if(din_valid = '1') then
          mask_next <= X"4000";
          remainder_next <= unsigned(din);
          root_next <= (others=>'0');
          if mask > remainder then
            mask_next <= "00"&mask(15 downto 2);
          end if;
          state_next <= PART1;
        end if;

      when PART1=>
        if(mask > remainder) then
          mask_next <= "00" & mask(15 downto 2);
          if ("00" & mask(15 downto 2)) <= remainder then
            state_next <= PART2;
          end if;
        else
            state_next <= PART2;          
        end if;

      when PART2=>
        if mask /= 0 then
          if (remainder >= (root + mask)) then
            remainder_next <= remainder - (root + mask);
            root_next <= ("0"&root(15 downto 1)) + mask;
          else
            root_next <= "0" & root(15 downto 1);
          end if;
          mask_next <= "00" & mask(15 downto 2);
         -- if("00" & mask(15 downto 2) = 0) then
           -- state_next <= IDLE;
           -- dout_ready <= '1';
         -- end if;
        
        else --TODO : we could save a clock by optimizing this
          if(remainder > root) then
            root_next <= root + 1;
          end if;
          state_next <= IDLE;
          dout_ready <= '1';
       end if;
    end case;
    
  end process;
  
  dout <= std_logic_vector(root_next(7 downto 0) );
end architecture;

               
