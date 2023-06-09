library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is

-- senales de la etapa IF

	signal pc_branch: std_logic_vector(31 downto 0);
	signal pc_plus_4: std_logic_vector(31 downto 0);
	signal next_pc: std_logic_vector(31 downto 0);
	signal pc: std_logic_vector(31 downto 0);
	signal pc_src: std_logic;
	signal instruction: std_logic_vector(31 downto 0);

	signal if_pc_plus_4: std_logic_vector(31 downto 0);
	signal if_instruction: std_logic_vector(31 downto 0);

-- senales de la etapa ID
	signal signal_extend: std_logic_vector(31 downto 0);

	component Registers

		Port(
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

	signal read_data_1: std_logic_vector(31 downto 0);
	signal read_data_2: std_logic_vector(31 downto 0);



-- senales de la Unidad de Control
	signal RegDst: std_logic_vector;
	signal ALUSrc: std_logic_vector;
	signal MemtoReg: std_logic_vector;
	signal RegWrite: std_logic_vector;
	signal MemRead: std_logic_vector;
	signal MemWrite: std_logic_vector;
	signal Branch: std_logic_vector;
	signal ALUOp: std_logic_vector(2 downto 0);


-- senales de registro de segmentacion ID/EX
	signal ID_RegDst: std_logic_vector;
	signal ID_ALUSrc: std_logic_vector;
	signal ID_MemtoReg: std_logic_vector;
	signal ID_MemRead: std_logic_vector;
	signal ID_MemWrite: std_logic_vector;
	signal ID_Branch: std_logic_vector;
	signal ID_ALUOp: std_logic_vector(2 downto 0);
	signal ID_pc_plus_4: std_logic_vector(31 downto 0);
	signal ID_read_data_1: std_logic_vector(31 downto 0);
	signal ID_read_data_2: std_logic_vector(31 downto 0);
	signal ID_signal_extend: std_logic_vector(31 downto 0);
	signal ID_instruction_20_16: std_logic_vector(4 downto 0);
	signal ID_instruction_15_11: std_logic_vector(4 downto 0);

-- senales de la etapa EX

	signal mux_ALU: std_logic_vector(31 downto 0);
	signal out_ALU_control: std_logic_vector(2 downto 0);
	signal zero_ALU: std_logic;
	signal result_ALU: std_logic_vector(31 downto 0);
	signal mux_instruction: std_logic_vector(4 downto 0);
	signal add_jump: std_logic_vector(31 downto 0);

	Component ALU 
		Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
			b : in STD_LOGIC_VECTOR (31 downto 0);
			control : in STD_LOGIC_VECTOR (2 downto 0);
			result : out STD_LOGIC_VECTOR (31 downto 0);
			zero : out STD_LOGIC);
	end component;
	
-- se�ales del registro de segmentacion EX/MEM
	signal EX_MemtoReg: std_logic_vector;
	signal EX_MemRead: std_logic_vector;
	signal EX_MemWrite: std_logic_vector;
	signal EX_Branch: std_logic_vector;
	signal EX_zero_ALU: std_logic;
	signal EX_result_ALU: std_logic_vector(31 downto 0);
	signal EX_mux_instruction: std_logic_vector(4 downto 0);
	signal EX_add_jump: std_logic_vector(31 downto 0);
	signal EX_read_data_2: std_logic_vector(31 downto 0);


-- Etapa de WB
	signal WB_write_register: std_logic_vector(4 downto 0);
	signal WB_write_data: std_logic_vector(31 downto 0);
	signal WB_write: std_logic;


begin 	

	next_pc <= pc_plus_4 when (pc_src = '0') else pc_branch;

	pc_plus_4 <= pc+4;

	process(Clk,Reset)
	begin
		if (Reset = '1') then
			pc <= x"00000000";
		elsif (rising_edge(Clk)) then
			pc <= next_pc;  
		end if;
	end process;


	I_Addr <= pc;
	I_RdStb <= '1';
	I_WrStb <= '0';
	I_DataOut <= x"00000000";

-- Registro de segmentacion IF/ID
	process(Clk,Reset)
	begin
		if (Reset = '1') then
			if_instruction <= x"00000000";
			if_pc_plus_4 <= x"00000000";
		elsif (rising_edge(Clk)) then
			if_instruction <= I_DataIn;
			if_pc_plus_4 <= pc_plus_4;
		end if;
	end process;

-- Extension de signo

	signal_extend <= x"0000" & if_instruction(15 downto 0) when (if_instruction(15) = '0')
	else x"ffff" & if_instruction(15 downto 0);

-- Declaracion de banco de registros

	bank_reg: Registers
	port map(
		clk => Clk,
		reset => Reset,
		wr => WB_write,
		reg1_rd => if_instruction(25 downto 21),
		reg2_rd => if_instruction(20 downto 16),
		reg_wr => WB_write_register, 
		data_wr => WB_write_data,
		data1_rd => read_data_1,
		data2_rd => read_data_2
	);

-- Unidad de control
	process(if_instruction)
	begin
		case if_instruction(31 downto 26) is
			when "000000" => -- r-type
				RegDst <= "1";
				ALUSrc <= "0";
				MemtoReg <= "0";
				RegWrite <= "1";
				MemRead <= "0";
				MemWrite <= "0";
				Branch <= "0";
				ALUOp <= "010";
			when "100011" => -- lw
				RegDst <= "0";
				ALUSrc <= "1";
				MemtoReg <= "1";
				RegWrite <= "1";
				MemRead <= "1";
				MemWrite <= "0";
				Branch <= "0";
				ALUOp <= "000";
			when "101011" => -- sw
				RegDst <= "0";
				ALUSrc <= "1";
				MemtoReg <= "0";
				RegWrite <= "0";
				MemRead <= "0";
				MemWrite <= "1";
				Branch <= "0";
				ALUOp <= "000";
			when "000100" => -- beq
				RegDst <= "0";
				ALUSrc <= "0";
				MemtoReg <= "0";
				RegWrite <= "0";
				MemRead <= "0";
				MemWrite <= "0";
				Branch <= "1";
				ALUOp <= "001";
			when "001000" => -- addi
				RegDst <= "0";
				ALUSrc <= "1";
				MemtoReg <= "0";
				RegWrite <= "1";
				MemRead <= "0";
				MemWrite <= "0";
				Branch <= "0";
				ALUOp <= "011";
			when "001100" => -- andi
				RegDst <= "0";
				ALUSrc <= "1";
				MemtoReg <= "0";
				RegWrite <= "1";
				MemRead <= "0";
				MemWrite <= "0";
				Branch <= "0";
				ALUOp <= "100";
			when "001101" => -- ori
				RegDst <= "0";
				ALUSrc <= "1";
				MemtoReg <= "0";
				RegWrite <= "1";
				MemRead <= "0";
				MemWrite <= "0";
				Branch <= "0";
				ALUOp <= "101";
			when "001101" => -- lui
				RegDst <= "0";
				ALUSrc <= "1";
				MemtoReg <= "0";
				RegWrite <= "1";
				MemRead <= "0";
				MemWrite <= "0";
				Branch <= "0";
				ALUOp <= "111";
            when others => -- otro caso
                RegDst <= "0";
				ALUSrc <= "0";
				MemtoReg <= "0";
				RegWrite <= "0";
				MemRead <= "0";
				MemWrite <= "0";
				Branch <= "0";
				ALUOp <= "000";
		end case;

	end process;

-- Registro de segmentacion ID/EX
	process(Clk,Reset)
	begin
		if (Reset = '1') then 
            ID_RegDst <= "0";
			ID_ALUSrc <= "0";
			ID_MemtoReg <= "0";
			ID_MemRead <= "0";
			ID_MemWrite <= "0";
			ID_Branch <= "0";
			ID_ALUOp <= "000";
			ID_pc_plus_4 <= x"00000000";
			ID_read_data_1 <= x"00000000";
			ID_read_data_2 <= x"00000000";
			ID_signal_extend <= x"00000000";
			ID_instruction_20_16 <= x"00000";
			ID_instruction_15_11 <= x"00000";
		elsif (rising_edge(Clk)) then
            ID_RegDst <= RegDst;
			ID_ALUSrc <= ALUSrc;
			ID_MemtoReg <= MemtoReg;
			ID_MemRead <= MemRead;
			ID_MemWrite <= MemWrite;
			ID_Branch <= Branch;
			ID_ALUOp <= ALUOp;
			ID_pc_plus_4 <= if_pc_plus_4;
			ID_read_data_1 <= read_data_1;
			ID_read_data_2 <= read_data_2;
			ID_signal_extend <= signal_extend;
			ID_instruction_20_16 <= if_instruction(20 downto 16);
			ID_instruction_15_11 <= if_instruction(15 downto 11);
		end if;
	end process;

-- Declaracion de la ALU

	mux_ALU <= ID_read_data_2 when (ID_ALUSrc = "0") else ID_signal_extend;
	out_ALU_control <= "000"; --revisar

-- ALU control
	process(ID_signal_extend, ID_ALUOp)
		begin
		case ID_ALUOp is
		when "010" =>
			if (ID_signal_extend(5 downto 0) = "100000") then
				out_ALU_control <= "010";
			elsif (ID_signal_extend(5 downto 0) = "100010") then
				out_ALU_control <= "110";
			elsif (ID_signal_extend(5 downto 0) = "100100") then
				out_ALU_control <= "000";
			elsif (ID_signal_extend(5 downto 0) = "100101") then
				out_ALU_control <= "001";
			elsif (ID_signal_extend(5 downto 0) = "101010") then
				out_ALU_control <= "111";
			else out_ALU_control <= "000";
			end if;
		when "000" => out_ALU_control <= "010";
		when "001" => out_ALU_control <= "110";
		when "011" => out_ALU_control <= "010";
		when "100" => out_ALU_control <= "000";
		when "101" => out_ALU_control <= "001";
		when "111" => out_ALU_control <= "100";
		when others => out_ALU_control <= "000";
		end case;
	end process;

	EX_ALU: ALU
		port map(
		a => ID_read_data_1,
		b => mux_ALU,
		control => out_ALU_control,
		zero => zero_ALU,
		result => result_ALU
		);

	add_jump <= (ID_signal_extend(29 downto 0) & "00") + ID_pc_plus_4;

	mux_instruction <= ID_instruction_20_16 when (ID_RegDst = "0") else ID_instruction_15_11;
-- Registro de segmentacion EX/MEM
	process(Clk,Reset)
	begin
		if (Reset = '1') then 
			EX_MemtoReg <= "0";
			EX_MemRead <= "0";
			EX_MemWrite <= "0";
			EX_Branch <= "0";
			EX_add_jump <= x"00000000";
			EX_zero_ALU <= '0';
			EX_result_ALU <= x"00000000";
			EX_read_data_2 <= x"00000000";
			EX_mux_instruction <= x"00000";
		elsif (rising_edge(Clk)) then
			EX_MemtoReg <= ID_MemtoReg;
			EX_MemRead <= ID_MemRead;
			EX_MemWrite <= ID_MemWrite;
			EX_Branch <= ID_Branch;
			EX_add_jump <= add_jump;
			EX_zero_ALU <= zero_ALU;
			EX_result_ALU <= result_ALU;
			EX_read_data_2 <= ID_read_data_2;
			EX_mux_instruction <= mux_instruction;
		end if;
	end process;
	

end processor_arq;
