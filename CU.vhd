library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cu is
  generic (
    N : natural := 3
  );
  port (
    reset_n, fast_clk : in std_logic;
    mvup, mvdn, opnd : out std_logic;
    req : in std_logic_vector(6 - 1 downto 0);
    floor_out : out std_logic_vector(7 - 1 downto 0)
  );
end cu;

architecture arch of cu is

  type state is (idle, start_up, movingup, start_dn, movingdn, opendoor, closedoor, waiting);
  signal current_state, next_state : state := idle;
  signal upLED, dnLED, doorLED : std_logic := '0';
  signal requested_floors, ext, extup : std_logic_vector(N - 1 downto 0) := (others => '0');
  signal counter : unsigned(1 downto 0);
  signal start_timer : std_logic;
  signal current_floor, far_req_floor : natural := 0;
  signal done : std_logic := '0';
  component seg_decoder
    port (
      in_decoder : in std_logic_vector(4 - 1 downto 0);
      out_decoder : out std_logic_vector(7 - 1 downto 0)
    );
  end component;
  component timer
    port (
      reset : in std_logic;
      clkInput : in std_logic;
      clkOutput : out unsigned(1 downto 0)
    );
  end component;
  function assign_far_floor(requested_floors, ext, extup : std_logic_vector(N - 1 downto 0); current_floor : natural; downBool : std_logic)
    return natural is
    variable target : natural;

  begin

    if (downBool = '1') or current_floor = N - 1 then
      target := 0;
      for i in requested_floors'low to requested_floors'high loop
        if requested_floors(i) = '1' then
          if ext(i) = '0' or (ext(i) = '1' and extup(i) = '0') then
          target := i;
          return target;
          end if;
        end if;
      end loop;

    else

      target := N - 1;
      for i in requested_floors'high downto requested_floors'low loop
        if requested_floors(i) = '1' then
          if ext(i) = '0' or (ext(i) = '1' and extup(i) = '1') then
            target := i;
            return target;
            end if;
        end if;
      end loop;

    end if;
    return target;
  end assign_far_floor;
begin

  upLED <= '1' when current_state = movingup else '0';
  dnLED <= '1' when current_state = movingdn else '0';
  doorLED <= '1' when current_state = opendoor or current_state = waiting else '0';

  mvup <= upLED;
  mvdn <= dnLED;
  opnd <= doorLED;

  seg_decoder_inst : seg_decoder
  port map(
    in_decoder => std_logic_vector(to_unsigned(current_floor, 4)),
    out_decoder => floor_out
  );
  timer_inst : timer
  port map(
    reset => start_timer,
    clkInput => fast_clk,
    clkOutput => counter
  );
  process (reset_n, current_state, requested_floors, far_req_floor, counter, current_floor)
    variable downBool : std_logic;
    variable  counter_last : unsigned(1 downto 0) := (others => '0') ;
  begin

    if reset_n = '0' then
      current_floor <= 0;
      far_req_floor <= current_floor;
      done <= '0';
    else
      case current_state is
        when idle =>
          if (unsigned(requested_floors) = 0) then
            next_state <= idle;
          else
            if far_req_floor < current_floor then
              downBool := '1';
            else
              downBool := '0';
            end if;
            far_req_floor <= assign_far_floor(requested_floors, ext, extup, current_floor, downBool);
            if
              (far_req_floor) >= current_floor then
              next_state <= start_up;

            else
              next_state <= start_dn;
            end if;
          end if;
        when start_up =>

          start_timer <= '1';
          counter_last := "00";
          next_state <= movingup;
        when movingup =>
          start_timer <= '0';
          if requested_floors(current_floor) = '1' then
            next_state <= opendoor;
            done <= '1';
          elsif counter_last /= counter then
            counter_last := counter;
            if counter_last = "10" then
              current_floor <= current_floor + 1;
            end if;
          elsif counter_last = "10" then
            next_state <= start_up;
          else next_state <= movingup;
          end if;

        when start_dn =>

          start_timer <= '1';
          counter_last := "00";
          next_state <= movingdn;
        when movingdn =>
          start_timer <= '0';
          if requested_floors(current_floor) = '1' then
            next_state <= opendoor;
            done <= '1';
          elsif counter_last /= counter then
            counter_last := counter;
            if counter_last = "10" then
              current_floor <= to_integer(resize(to_unsigned(current_floor, 4) + "1111", 4));
            end if;
          elsif counter_last = "10" then
            next_state <= start_dn;
          else next_state <= movingdn;
          end if;
        when opendoor =>
          start_timer <= '1';
          next_state <= waiting;
        when waiting =>
          done <= '0';
          start_timer <= '0';
          if counter = "10" then
            next_state <= closedoor;
          else next_state <= waiting;
          end if;
        when closedoor =>
          next_state <= idle;
      end case;
    end if;
  end process;

  main : process (fast_clk, reset_n)
    variable req_floor_nu : natural := 0;
  begin

    if (reset_n = '0') then
      current_state <= idle;
      requested_floors <= std_logic_vector(to_unsigned(0, requested_floors'length));
    elsif (fast_clk'event and fast_clk = '1') then
      current_state <= next_state;
      if done = '1' then
        requested_floors(current_floor) <= '0';
      end if;
      if (req(6 - 3 downto 0)) /= "1111" then
        req_floor_nu := to_integer(unsigned(req(6 - 3 downto 0)));
        requested_floors(req_floor_nu) <= '1';
        if (req(6 - 1)) = '1' then
          ext(req_floor_nu) <= '1';
          if (req(6 - 2)) = '1' then
            extup(req_floor_nu) <= '1';
          else extup(req_floor_nu) <= '0';
          end if;
        else ext(req_floor_nu) <= '0';
        end if;

      end if;

    end if;

  end process; -- main
end architecture;