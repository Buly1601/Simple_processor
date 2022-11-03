package main_parameters is
    constant m: natural := 8; -- m-bit processor
end main_parameters;
library IEEE; use IEEE.std_logic_1164.all;
use work.main_parameters.all;

entity processor is
    port(
        -- input ports of the entire system
        INPUT_DATA : in std_logic_vector(15 downto 0)
    );
end processor;

architecture structure of processor is

    signal write_reg, out_en: std_logic;
    signal result, reg_in, left_out, right_out: std_logic_vector(m-1 downto 0); 

    -- input selection
    component input_selection is 
        port(
            IN0, IN1, IN2, IN3, IN4, IN5, IN6, IN7: in std_logic_vector(m-1 downto 0);
            A, result: in std_logic_vector(m-1 downto 0);
            j: in std_logic_vector(2 downto 0);
            input_control: in std_logic_vector(1 downto 0);
            to_reg: out std_logic_vector(m-1 downto 0)
        );
    end component;

    -- computation resources
    component computation_resources is
        port(
            left_in, right_in: in std_logic_vector(m-1 downto 0);
            f: in std_logic;
            result: out std_logic_vector(m-1 downto 0)
        );
    end component;

    -- output selection
    component output_selection is
        port(
            A, reg: in std_logic_vector(m-1 downto 0);
            clk, out_en, out_sel: in std_logic;
            i: in std_logic_vector(2 downto 0);
            OUT0, OUT1, OUT2, OUT3, OUT4, OUT5, OUT6, OUT7: out std_logic_vector(m-1 downto 0)
        );
    end component;
end structure;