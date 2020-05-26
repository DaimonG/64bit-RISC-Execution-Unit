
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;

Entity LogicUnit is
Generic(N:natural := 64); 
Port(A, B: in std_logic_vector(N-1 downto 0); 
	Y: out std_logic_vector(N-1 downto 0);
	LogicFN: in std_logic_vector(1 downto 0)); 
End Entity LogicUnit; 

Architecture rtl of LogicUnit is
-- Internal Signal Declarations
signal XORInternal: std_logic_vector(N-1 downto 0); 
signal ORInternal: std_logic_vector(N-1 downto 0); 
signal ANDInternal: std_logic_vector(N-1 downto 0); 
Begin
	XORInternal <= B XOR A; -- 64 bit XOR gate
	ORInternal <= B OR A; -- 64 bit OR gate
	ANDInternal <= B AND A; -- 64 bit XOR gate

	-- Implementation of a 4 channel MUX using LogicFN as control signals
	with LogicFN select
		Y <= XORInternal when "01", -- Select XOR
		 ORInternal when "10", -- Select OR
		 ANDInternal when "11", -- Select AND
		 B when others;		-- Select B Pass Through
End Architecture rtl;