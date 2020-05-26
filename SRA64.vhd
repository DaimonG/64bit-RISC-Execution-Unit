-- Import Required Libraries
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.math_real.all; -- For ceil, log2, and real functions

-- Entity Declaration
-- X is the input of the barrel shifter
-- Y is the output of the barrel shifter
-- ShiftCount is the control signal used by all of the MUXs
Entity SRA64 is
Generic ( N : natural := 64 );
Port ( X : in std_logic_vector( N-1 downto 0 );
	Y : out std_logic_vector( N-1 downto 0 );
	ShiftCount : in unsigned( integer(ceil(log2(real(N))))-1 downto 0 ) );
End Entity SRA64;

Architecture rtl of SRA64 is
-- Internal Signal Declarations
-- Signals used by the first MUX
signal shift16Internal: std_logic_vector(N-1 downto 0); -- Used to shift 16 bits
signal shift32Internal: std_logic_vector(N-1 downto 0); -- Used to shift 32 bits
signal shift48Internal: std_logic_vector(N-1 downto 0); -- Used to shift 48 bits
signal firstMUXOut: std_logic_vector(N-1 downto 0); -- Output of the first MUX

-- Signals used by the second MUX
signal shift4Internal: std_logic_vector(N-1 downto 0); -- Used to shift 4 bits
signal shift8Internal: std_logic_vector(N-1 downto 0); -- Used to shift 8 bits
signal shift12Internal: std_logic_vector(N-1 downto 0); -- Used to shift 12 bits
signal secondMUXOut: std_logic_vector(N-1 downto 0); -- Output of the second MUX

-- Signals used by the third MUX
signal shift1Internal: std_logic_vector(N-1 downto 0); -- Used to shift 1 bits
signal shift2Internal: std_logic_vector(N-1 downto 0); -- Used to shift 2 bits
signal shift3Internal: std_logic_vector(N-1 downto 0); -- Used to shift 3 bits

Begin
-- First Set of Shift Operations
    -- Perform 16 bit shift
    shift16Internal(N-1 downto 0) <= (15 downto 0 => X(N-1)) & X(N-1 downto 16); -- shifting bits right 16 and filling upper bits with sign bit

    -- Perform 32 bit shift
    shift32Internal(N-1 downto 0) <= (31 downto 0 => X(N-1)) & X(N-1 downto 32); -- shifting bits right 32 and filling upper bits with sign bit

    -- Perform 48 bit shift
    shift48Internal(N-1 downto 0) <= (47 downto 0 => X(N-1)) & X(N-1 downto 48); -- shifting bits right 48 and filling upper bits with sign bit

    -- Implementing first 64 bit, 4 channel MUX
    -- Ouputs the internal output to our internal signal of firstMUX
    with ShiftCount(5 downto 4) select
        firstMUXOut <= shift16Internal when "01", -- select 16 bit shift
        shift32Internal when "10", -- select 32 bit shift
        shift48Internal when "11", -- select 48 bit shift
        X when others; -- select 0 bit shift

-- Second Set of Shift Operations
    -- Perform 4 bit shift
    shift4Internal(N-1 downto 0) <= (3 downto 0 => firstMUXOut(N-1)) & firstMUXOut(N-1 downto 4); -- shifting bits right 4 and filling upper bits with sign bit
    -- Perform 8 bit shift
    shift8Internal(N-1 downto 0) <= (7 downto 0 => firstMUXOut(N-1)) & firstMUXOut(N-1 downto 8); -- shifting bits right 8 and filling upper bits with sign bit
    -- Perform 12 bit shift
    shift12Internal(N-1 downto 0) <= (11 downto 0 => firstMUXOut(N-1)) & firstMUXOut(N-1 downto 12); -- shifting bits right 12 and filling upper bits with sign bit

    -- Implementing Second 64 bit, 4 channel MUX
    -- Ouputs the internal output to our internal signal of secondMux
    with ShiftCount(3 downto 2) select
        secondMUXOut <= shift4Internal when "01", -- select 4 bit shift
        shift8Internal when "10", -- select 8 bit shift
        shift12Internal when "11", -- select 12 bit shift
        firstMUXOut when others; -- select 0 bit shift

-- Third Set of Shift Operations
    -- Perform 1 bit shift
    shift1Internal(N-1 downto 0) <= (0 downto 0 => secondMUXOut(N-1)) & secondMUXOut(N-1 downto 1); -- shifting bits right 1 and filling upper bits with sign bit
    -- Perform 2 bit shift
    shift2Internal(N-1 downto 0) <= (1 downto 0 => secondMUXOut(N-1)) & secondMUXOut(N-1 downto 2); -- shifting bits right 2 and filling upper bits with sign bit
    -- Perform 3 bit shift
    shift3Internal(N-1 downto 0) <= (2 downto 0 => secondMUXOut(N-1)) & secondMUXOut(N-1 downto 3); -- shifting bits right 3 and filling upper bits with sign bit

    -- Implementing Third 64 bit, 4 channel MUX
    -- Ouputs the final output to our output signal
    with ShiftCount(1 downto 0) select
        Y <= shift1Internal when "01", -- select 1 bit shift
        shift2Internal when "10", -- select 2 bit shift
        shift3Internal when "11", -- select 3 bit shift
        secondMUXOut when others; -- select 0 bit shift

End Architecture rtl;