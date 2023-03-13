library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rr is
  generic (
    N : natural := 10
  );
  port (
    clk : in std_logic;
    bns : in std_logic_vector(N - 1 downto 0);
    ups : in std_logic_vector(N - 1 downto 0);
    dns : in std_logic_vector(N - 1 downto 0);
    req : out std_logic_vector(6 - 1 downto 0)
  );
end rr;

architecture arch of rr is
  signal int : std_logic;

begin
  req(6 - 1) <= '1' when signed(ups) /= to_signed(-1, ups'length) or signed(dns) /= to_signed(-1, dns'length) else '0';
  req(6 - 2) <= '1' when signed(ups) /= to_signed(-1, ups'length) or signed(bns) /= to_signed(-1, bns'length) else '0';

  -- interrupt : process( bns, ups, dns, acklg )
  -- begin
  -- if (unsigned(ups) /= 255 or unsigned(dns) /= 255 or unsigned(bns) /= 255) and acklg = '0' then
  -- int <= '1';
  -- else

  -- end if;
  -- end process ; -- interrupt

  floor : process (clk, bns, ups, dns)
  begin
    if (clk'event and clk = '1') then
      int <= '0';
      for i in 0 to N - 1 loop
        if bns(i) = '0' or ups(i) = '0' or dns(i) = '0' then
          req(6 - 3 downto 0) <= std_logic_vector(to_unsigned(i, 4));
          int <= '1';
          exit;
        end if;
      end loop;
      if int = '0' then
        req(6 - 3 downto 0) <= "1111";
      end if;
    end if;
  end process; -- floor

end architecture;