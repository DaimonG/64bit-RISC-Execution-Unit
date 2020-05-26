Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;

Entity ExecUnit is
Generic ( N : natural := 64 ); -- parameter width of the input data
Port ( A, B : in std_logic_vector( N-1 downto 0 ); -- input data vectors
	NotA : in std_logic := '0'; -- controls inversion of A
	FuncClass, LogicFN, ShiftFN : in std_logic_vector( 1 downto 0 ); -- selects output between different logic, shift, arithmetic functions
	AddnSub, ExtWord : in std_logic := '0'; -- controls inversion of B and sign-extension of result
	Y : out std_logic_vector( N-1 downto 0 ); -- output result vector
	Zero, AltB, AltBu : out std_logic ); -- indicates zero result, A less than B, A less than B signed
End Entity ExecUnit;

Architecture rtl of ExecUnit is
	signal AddY, AddYDum 		: std_logic_vector( N-1 downto 0 ); -- internal signals adder output Y, and a dummy arithmetic unit final output Y
	signal ShiftY, LogicY		: std_logic_vector( N-1 downto 0 ); -- internal signals logic unit and shift unit outputs Y
	signal AdderCout, AdderOvfl, AdderAltB, AdderAltBu : std_logic; -- indicates adder status outputs carry-out bit, arithmetic overflow, A less than B, A less than B signed
begin
	
	-- Arithmetic Unit entity:
	-- inputs: A, B: N-bit operand terms; NotA, AddnSub: control input data inversion; ExtWord: control result sign-extension
	-- outputs: AddY: N-bit shift operation result; AddYDum: N-bit dummy final output; AdderCout, AdderOvfl, Zero, AdderAltB, AdderAltBu: output status signals
	EntArithUnit: entity Work.ArithUnit generic map (N)
		port map (A, B, AddY, AddYDum, NotA, AddnSub, ExtWord, AdderCout, AdderOvfl, Zero, AdderAltB, AdderAltBu);
	
	-- Shift Unit entity:
	-- inputs: A, B, AddY: N-bit operand terms; LogicFN: selected logic operation; ExtWord: control result sign-extension
	-- outputs: ShiftY: N-bit shift operation result
	EntShiftUnit: entity Work.ShiftUnit generic map (N)
		port map (A, B, AddY, ShiftY, ShiftFN, ExtWord);
	
	-- Logic Unit entity:
	-- inputs: A, B: N-bit operand terms; LogicFN: selected logic operation
	-- outputs: LogicY: N-bit logic operation result
	EntLogicUnit: entity Work.LogicUnit generic map (N)
		port map (A, B, LogicY, LogicFN);
	
	-- assign only 2 status signals from ArithUnit to indicate comparison result between A and B for signed and unsigned
	AltB <= AdderAltB;
	AltBu <= AdderAltBu;
	
	--final output MUX, selects between Adder status outputs and results of logic and shift operations
	with FuncClass select
		Y <= LogicY when "11",
			ShiftY when "10",		
			((N-1 downto 1 => '0') & AdderAltB) when "01",
			((N-1 downto 1 => '0') & AdderAltBu) when others;
	
End Architecture rtl;