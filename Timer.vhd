library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
  port (
    reset : in std_logic;
    clkInput : in std_logic;
    clkOutput : out unsigned(1 downto 0)
  );
end timer;

architecture arch of timer is
   signal count : unsigned(25 downto 0) := (others => '0');
begin
  process (clkInput, reset)
  
    variable clkOutVar : unsigned(1 downto 0);
  begin
    clkOutput <= clkOutVar;
    if (reset = '1') then
      count <= (others => '0');
      clkOutVar := (others => '0');
    elsif rising_edge(clkInput) then
      if (count = 50000000) then
        clkOutVar := clkOutVar + 1;
        count <= (others => '0');
      else
        count <= count + 1;
      end if;
    end if;
  end process;

end architecture;