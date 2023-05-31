library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity ALU is
    Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           control : in STD_LOGIC_VECTOR (2 downto 0);
           result : out STD_LOGIC_VECTOR (31 downto 0);
           zero : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

	-- Signals between operations/mux
	signal op_and : STD_LOGIC_VECTOR(31 downto 0);
	signal op_or : STD_LOGIC_VECTOR(31 downto 0);
	signal op_sum : STD_LOGIC_VECTOR(31 downto 0);
	signal op_rest: STD_LOGIC_VECTOR(31 downto 0);
	signal op_less : STD_LOGIC_VECTOR(31 downto 0);
	signal op_left : STD_LOGIC_VECTOR(31 downto 0);

	-- Signal between mux/exit
    signal r: STD_LOGIC_VECTOR(31 downto 0);
begin

	op_and <= (a and b);
	op_or <= (a or b);
	op_less <= (others => '0') when b < a else x"00000001";
	op_sum <= std_logic_vector(signed(a) + signed(b));
	op_rest <= std_logic_vector(signed(a) - signed(b));
	op_left <= b(15 downto 0) & x"0000";
    

    with control select
        r <=
            op_and when "000",
			op_or when "001",
			op_sum when "010",
			op_rest when "110",
            op_left when "100",
			op_less when others;
	
	zero <= '1' when (r = x"00000000") else '0';
	result <= r;
end Behavioral;
