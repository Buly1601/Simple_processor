package main_parameters is
    constant m: natural := 8; -- m-bit processor
end main_parameters;
use work.main_parameters.all;
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity computation_resources is
    port (
    left_in, right_in: in std_logic_vector(m-1 downto 0);
    f: in std_logic;
    result: out std_logic_vector(m-1 downto 0)
    );
end computation_resources;

architecture behavior of computation_resources is
    begin
    process(f, left_in, right_in)
        begin
        if f = '0' then result <= left_in + right_in;
        else result <= left_in - right_in;
        end if;
    end process;
end behavior;