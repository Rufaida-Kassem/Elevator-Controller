library ieee;
use ieee.std_logic_1164.all;

entity seg_decoder is
  port (
    in_decoder : in std_logic_vector(4-1 downto 0);
    out_decoder : out std_logic_vector(7-1 downto 0));
end seg_decoder;

architecture Behavior of seg_decoder is
begin
	process(in_decoder)
	begin
		case(in_decoder) is 
			when "0000"=> out_decoder<="1000000";
			when "0001"=> out_decoder<="1111001";
			when "0010"=> out_decoder<="0100100";
			when "0011"=> out_decoder<="0110000";
			when "0100"=> out_decoder<="0011001";
			when "0101"=> out_decoder<="0010010";
			when "0110"=> out_decoder<="0000010";
			when "0111"=> out_decoder<="1111000";
			when "1000"=> out_decoder<="0000000";
			when "1001"=> out_decoder<="0010000";
			when others => out_decoder<="1111111";	
		end case;	
	end process;


end Behavior;