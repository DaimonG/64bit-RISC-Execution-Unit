Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

Entity ArithUnit is
Generic ( N : natural := 64 ); -- parameter width of the input data
Port ( A, B : in std_logic_vector( N-1 downto 0 ); -- input data vectors addition terms
	AddY, Y : out std_logic_vector( N-1 downto 0 ); -- adder and final output sums of the inputs A and B
-- Control signals
	NotA, AddnSub, ExtWord : in std_logic := '0'; -- controls inversion of A, inversion of B, sign-extension of result
-- Status signals
	Cout, Ovfl, Zero, AltB, AltBu : out std_logic ); -- indicates carry-out bit, arithmetic overflow, zero result, A less than B, A less than B signed
End Entity ArithUnit;

Architecture rtl of ArithUnit is
    signal     AdderA, AdderB, AdderS, ExtY	: std_logic_vector(N-1 downto 0); -- internal signals for adder inputs A and B, adder output Y, extended version of adder output Y
    signal     AdderCout, AdderOvfl			: std_logic; -- indicates adder status outputs carry-out bit, arithmetic overflow
begin
	-- MUXes controlling input inversion based on control signals
	AdderA <= A when NotA = '0' else NOT A;
	AdderB <= B when AddnSub = '0' else NOT B;
	
	-- Adder entity:
	-- inputs: AdderA, AdderB: 64-bit operand terms; AddnSub: 1-bit carry-in
	-- outputs: AdderS: 64-bit arithmetic result; AdderCout, AdderOvfl: 1-bit carry-out and overflow statuses
	EntAdder: entity Work.Adder generic map (N) port map (AdderA, AdderB, AdderS, AddnSub, AdderCout, AdderOvfl);
	
	--sign-extended Adder result
	ExtY <= (N/2-1 downto 0 => AdderS(N/2-1)) & AdderS(N/2-1 downto 0);
	
	-- MUX controlling final result output based on whether extension is needed
	Y <= AdderS when ExtWord = '0' else ExtY;
	AddY <= AdderS;
	
	-- status signal assignment
	Cout <= AdderCout;
	Ovfl <= AdderOvfl;
	Zero <= nor_reduce(AdderS); --using nor to reduce vector to single bit
	AltBu <= NOT AdderCout ; --using not to reduce vector to single bit, return 1 if A less than B (unsigned)
	AltB <= AdderOvfl XOR AdderS(N-1); --return 1 if A less than B (signed)

End Architecture rtl;