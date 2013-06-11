---------------------------------------------------------------------------
-- Copyright (C) 2013 Ron Pedde <ron@pedde.com>
--
-- Power-on reset circuit.  It sits on a spin for a number of cycles
-- with reset low, then raises it after some time.
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity poreset is port (
  clk      : in  std_logic;
  reset_in : in  std_logic;
  reset_out: out std_logic := '0'
  );
end poreset;

architecture behavioral of poreset is
  signal countdown: std_logic_vector(20 downto 0) := "00000000000000000000";
begin
  porset_p: process(clk) begin
    if(clk'event and clk = '1') then
      if(reset_in = '1') then
        if(countdown(20) = '0') then
          countdown <= countdown + 1;
        else
          reset_out <= '0';
        end if;
      else
        countdown <= '0';
        reset_out <= '0';
      end if;
    end if;
  end process;
end behavioral;
