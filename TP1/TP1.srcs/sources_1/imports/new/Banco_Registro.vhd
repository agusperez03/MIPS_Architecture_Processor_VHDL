library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Registers is
    Port ( clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			wr : in STD_LOGIC;
			reg1_rd : in STD_LOGIC_VECTOR (4 downto 0);
			reg2_rd : in STD_LOGIC_VECTOR (4 downto 0);
			reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
			data_wr : in STD_LOGIC_VECTOR (31 downto 0);
			data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
			data2_rd : out STD_LOGIC_VECTOR (31 downto 0)
		);
end Registers;

architecture Behavioral of Registers is


type Mem is array (31 downto 0) of std_logic_vector (31 downto 0);
signal Regs: Mem;

begin

	data1_rd <= Regs(to_integer(unsigned(reg1_rd))) when (reg1_rd /= "00000") else x"00000000";
	data2_rd <= Regs(to_integer(unsigned(reg2_rd))) when (reg2_rd /= "00000") else x"00000000";

    process(reset,clk)
    begin
        if (reset = '1') then
            for i in 0 to 31 loop
                Regs(i) <= (others => '0'); -- Poner todos los registros en 0
            end loop;
        elsif (falling_edge(clk)) then
			if (wr = '1') then
				Regs(to_integer(unsigned(reg_wr))) <= data_wr;
			end if;
        end if;
    end process;  

end Behavioral;