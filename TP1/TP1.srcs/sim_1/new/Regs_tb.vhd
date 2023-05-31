library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Regs_tb is
end Regs_tb;

architecture regs_beh of Regs_tb is

    component Registers is
		port(
			clk: in std_logic;
			reset: in std_logic;
			wr: in std_logic;
			reg1_rd: in std_logic_vector(4 downto 0);
			reg2_rd: in std_logic_vector(4 downto 0);
			reg_wr: in std_logic_vector(4 downto 0);
			data_wr: in std_logic_vector(31 downto 0);
			data1_rd: out std_logic_vector(31 downto 0);
			data2_rd: out std_logic_vector(31 downto 0)
		);
    end component;

	signal clk: std_logic;
	signal reset: std_logic;
	signal wr: std_logic;
	signal reg1_rd: std_logic_vector(4 downto 0);
	signal reg2_rd: std_logic_vector(4 downto 0);
	signal reg_wr: std_logic_vector(4 downto 0);
	signal data_wr: std_logic_vector(31 downto 0);
	signal data1_rd: std_logic_vector(31 downto 0);
	signal data2_rd: std_logic_vector(31 downto 0);
begin

uut: Registers port map(
	clk => clk,
	reset => reset,
	wr => wr,
	reg1_rd => reg1_rd,
	reg2_rd => reg2_rd,
	reg_wr => reg_wr,
	data_wr => data_wr,
	data1_rd => data1_rd,
	data2_rd => data2_rd
);

clk_process: process
begin
	clk <= '0';
	wait for 10 ns;
	clk <= '1';
	wait for 10 ns;
end process;

tb: process
begin
-- hacer loop para cargar el banco

	reset <= '1';
	wr <= '0';
	reg1_rd <= "00000";
	reg2_rd <= "00000";
	reg_wr <= "00000";
	data_wr <= x"00000000";

	wait for 10 ns;
	reset <= '0';
	wr <= '1';
	reg_wr <= "00001";
	data_wr <= x"00000001";
	reg1_rd <= "00001";
	reg2_rd <= "00001";


	wait;


end process;


end regs_beh;
