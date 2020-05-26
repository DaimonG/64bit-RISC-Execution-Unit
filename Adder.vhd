library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity Adder is
Generic ( N : natural := 64 ); -- parameter width of the input data
Port ( A, B : in std_logic_vector( N-1 downto 0 ); -- input data vectors addition terms
	Y : out std_logic_vector( N-1 downto 0 ); -- output sum of the inputs A and B
-- Control signals
	Cin : in std_logic; -- indicates carry-in bit to the calculation
-- Status signals
	Cout, Ovfl : out std_logic ); -- indicates carry-out bit and arithmetic overflow
End Entity Adder;

Architecture rtl of Adder is
    signal     G, P, t	: std_logic_vector(N-1 downto 0); -- internal signals for generate, propagate network outputs
    signal     C		: std_logic_vector(N downto 0); -- internal signal for carry network output, 1 more bit than inputs
begin

	--GP network: create vectors for generate and propagate bits
    bitcellGP: for i in N-1 downto 0
    generate begin
		G(i) <= A(i) AND B(i);
		P(i) <= A(i) XOR B(i);
    end generate bitcellGP;
	 
	C(0) <= Cin; -- assign carry-in to first bit of carry vector

	--C network: create vector for carry bits
	bitcellC: for i in N-1 downto 0
	generate begin
		t(i)	<= C(i) AND P(i);
		C(i+1)	<= G(i) OR t(i);
	end generate bitcellC;

	--S network: create vector for sum bits and assign it to output vector
	bitcellS: for i in N-1 downto 0
	generate begin
		Y(i) <= P(i) XOR C(i);
	end generate bitcellS;
	
	--assign status signals based on last 2 carry-out bits
	Cout <= C(N);
	Ovfl <= C(N) XOR C(N-1);
End Architecture rtl;