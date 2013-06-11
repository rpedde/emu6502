-------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    17:16:21 01/06/2013
-- Design Name:
-- Module Name:    ram_8k - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_8k is
    Port ( clk      : in  std_logic;
           addr     : in  std_logic_vector (12 downto 0);
           we       : in  std_logic;
           enable_n : in  std_logic;
           di       : in  std_logic_vector (7 downto 0);
           do       : out std_logic_vector (7 downto 0)
         );
end ram_8k;

architecture Behavioral of ram_8k is
  constant RAM_SIZE_C  : natural   := 8192;
  constant RAM_WIDTH_C : natural   := 8;

  subtype ramword_t is unsigned(RAM_WIDTH_C-1 downto 0); -- word type
  type ram_t is array(0 to RAM_SIZE_C-1) of ramword_t;  -- data

  impure function init_mem(mif_file_name : in string) return ram_t is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(RAM_WIDTH_C-1 downto 0);
    variable temp_mem : ram_t;
  begin
    for i in ram_t'range loop
      readline(mif_file, mif_line);
      read(mif_line, temp_bv);
      temp_mem(i) := unsigned(To_StdLogicVector(temp_bv));
    end loop;
    return temp_mem;
  end function;

  signal ram_r : ram_t := init_mem("rom.mif");
begin
  --This is implied distributed ram... we want block
  --ram_p: process (clk)
  --begin
  --  if (clk'event and clk = '1') then
  --    if(we = '1') then
  --      ram_r(to_integer(unsigned(addr))) <= unsigned(di);
  --    end if;
  --  end if;
  --end process;

  --do <= std_logic_vector(ram_r(to_integer(unsigned(addr))));

  ram_p: process(clk)
  begin
    if(enable_n = '0') then
      if(clk'event and clk = '1') then
        if (we = '1') then
          ram_r(to_integer(unsigned(addr))) <= unsigned(di);
        end if;
        do <= std_logic_vector(ram_r(to_integer(unsigned(addr))));
      end if;
    end if;
  end process;

end Behavioral;
