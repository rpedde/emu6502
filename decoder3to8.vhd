---------------------------------------------------------------------------
-- Copyright (C) 2013 Ron Pedde <ron@pedde.com>
--
-- Simple 3 to 8 decoder for address decoding
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder3to8 is port (
  a   : in  std_logic_vector(2 downto 0);
  e   : out std_logic_vector(7 downto 0)
  );
end decoder3to8;

architecture Behavioral of decoder3to8 is begin
  decoder_p: process(a) begin
    case a is
      when "000"  => e <= "11111110";
      when "001"  => e <= "11111101";
      when "010"  => e <= "11111011";
      when "011"  => e <= "11110111";
      when "100"  => e <= "11101111";
      when "101"  => e <= "11011111";
      when "110"  => e <= "10111111";
      when "111"  => e <= "01111111";
      when others => e <= "11111111";
    end case;
  end process;
end Behavioral;
