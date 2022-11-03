package main_parameters is
    constant m: natural := 8; -- m-bit processor
end main_parameters;
library IEEE; use IEEE.std_logic_1164.all;
use work.main_parameters.all;

entity processor is
    port(
        -- input ports of the entire system
        INPUT_DATA : in std_logic_vector(15 downto 0);
        IN0, IN1, IN2, IN3, IN4, IN5, IN6, IN7: in std_logic_vector(m-1 downto 0);
        instruction: in std_logic_vector(15 downto 0);
        clk, reset: in std_logic;
        OUT0, OUT1, OUT2, OUT3, OUT4, OUT5, OUT6, OUT7: out std_logic_vector(m-1 downto 0);
        number: inout std_logic_vector(7 downto 0)
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





    -- component assignments
    input_selection_comp : input_selection
        port map (IN0 => IN0, IN1 => IN1, IN2 => IN2, IN3 => IN3, IN4 => IN4, IN5 => IN5, IN6 => IN6, IN7 => IN7,
        A => instruction(11 downto 4),
        result => result, j => instruction(6 downto 4),
        input_control => instruction(14 downto 13),
        to_reg => reg_in);
    

    computation_resources_comp : computation_resources
        port map (left_in => left_out, right_in => right_out,
        f => instruction(12), result => result);

    output_selection_comp : output_selection
        port map (A => instruction(7 downto 0), 
        reg => right_out,
        clk => clk, out_en => out_en,
        out_sel => instruction(13),
        i => instruction(10 downto 8), 
        OUT0 => OUT0, OUT1 => OUT1, OUT2 => OUT2, OUT3 => OUT3, OUT4 => OUT4, OUT5 => OUT5, OUT6 => OUT6, OUT7 => OUT7);

end structure;