library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity P1C_TB is
end P1C_TB;

architecture ALU_beh of P1C_TB is

	component ALU is
		Port ( a : in  std_logic_vector(31 downto 0);
			b : in  std_logic_vector(31 downto 0);
			control : in  std_logic_vector(2 downto 0);
			zero : out  std_logic;
			result : out  std_logic_vector(31 downto 0));
	end component;

	signal  a: std_logic_vector(31 downto 0);
	signal  b: std_logic_vector(31 downto 0);
	signal  control: std_logic_vector(2 downto 0);
	signal  zero: std_logic;
	signal  result: std_logic_vector(31 downto 0);

begin

	uut: ALU
    port map(
		a => a,
		b => b,
		control => control,
		zero => zero,
		result => result
    );

	tb: process
	begin

		a <= x"00000001";
		b <= x"00000003";
		control <= "000";

		wait for 10 ns;
		control <= "001";

		wait for 10 ns;
		control <= "010";

		wait for 10 ns;
		control <= "110";

		wait for 10 ns;
		control <= "100";

		wait for 10 ns;
		control <= "111";
		wait;

	end process;

end ALU_beh;
