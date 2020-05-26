Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.math_real.all;

Entity ShiftUnit is
Generic ( N : natural := 64 ); -- parameter width of the input data
Port ( A, B, C : in std_logic_vector( N-1 downto 0 ); -- input data vector A, shift amount B, carry-through signal C
	Y : out std_logic_vector( N-1 downto 0 ); -- output result vector
	ShiftFN : in std_logic_vector( 1 downto 0 ); -- controls which shifing operation to be selected
	ExtWord : in std_logic ); -- controls sign-extension of result
End Entity ShiftUnit;

Architecture rtl of ShiftUnit is
	signal shifterX, SLLY, SRLY, SRAY	: std_logic_vector( N-1 downto 0 ); -- internal signal for single common data input to all 3 shifters X, and 3 distinct outputs Y
	signal SLLorC, SLLorCExt		: std_logic_vector( N-1 downto 0 ); -- internal signal carrying result of selecting shifter outputs between SLL or carry-through based on shiftFN(0), and its sign-extended version
	signal SRLorSRA, SRLorSRAExt	: std_logic_vector( N-1 downto 0 ); -- internal signal carrying result of selecting shifter outputs between SRL or SLA based on shiftFN(0), and its sign-extended version
    signal shiftCount				: unsigned( integer(ceil(log2(real(N))))-1 downto 0 ); -- internal singal indicating number of bits to be shifted
begin
	shiftCount <= -- extract shift amount from B, extract lowest 5 bits for half-width data, and lowest 6 bits for full-width data
		unsigned(B(5 downto 0)) when ExtWord = '0'
		else unsigned('0' & B(4 downto 0));

	shifterX <= -- swap upper and lower halves of input if shift selected is SRL or SRA and data is half-width
		(A(N/2-1 downto 0) & A(N-1 downto N/2)) when (ShiftFN(1) = '1' AND ExtWord = '1') --SRL or SRA
		else A; --passC or SLL
	
	-- Shift Left Logical entity:
	-- inputs: shifterX: 64-bit operand terms; SLLShiftCount: 6-bit shift amount
	-- outputs: SLLY: 64-bit shift logical left operation result
	EntSLL64: entity Work.SLL64 generic map (N) port map (shifterX, SLLY, shiftCount);
	
	-- Shift Right Logical entity:
	-- inputs: shifterX: 64-bit operand terms; SLLShiftCount: 6-bit shift amount
	-- outputs: SRLY: 64-bit shift right logical operation result
	EntSRL64: entity Work.SRL64 generic map (N) port map (shifterX, SRLY, shiftCount);
	
	-- Shift Right Arithmetic entity:
	-- inputs: shifterX: 64-bit operand terms; SLLShiftCount: 6-bit shift amount
	-- outputs: SRAY: 64-bit shift right arithmetic operation result
	EntSRA64: entity Work.SRA64 generic map (N) port map (shifterX, SRAY, shiftCount);
	
	-- final MUXes selecting output between 4 possible results controlled by ShiftFN: carry-through, SLL, SRL, SRA
	-- results are sign extended approriately if input is half-width
	SLLorC <= SLLY when ShiftFN(0) = '1' else C;
	SLLorCExt <=
		((N-1 downto N/2 => SLLorC(N/2-1)) & SLLorC(N/2-1 downto 0)) when ExtWord = '1'
		else SLLorC;
	SRLorSRA <= SRAY when ShiftFN(0) = '1' else SRLY;
	SRLorSRAExt <=
		((N-1 downto N/2 => SRLorSRA(N-1)) & SRLorSRA(N-1 downto N/2)) when ExtWord = '1'
		else SRLorSRA;
	Y <= SRLorSRAExt when ShiftFN(1) = '1' else SLLorCExt;
	
End Architecture rtl;