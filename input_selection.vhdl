package main_parameters is
    constant m: natural := 8; -- m-bit processor
end main_parameters;
library IEEE; use IEEE.std_logic_1164.all;
use work.main_parameters.all;

entity input_selection is
    port (
    IN0, IN1, IN2, IN3, IN4, IN5, IN6, IN7: in std_logic_vector(m-1 downto 0);
    A, result: in std_logic_vector(m-1 downto 0);
    j: in std_logic_vector(2 downto 0);
    input_control: in std_logic_vector(1 downto 0);
    to_reg: out std_logic_vector(m-1 downto 0)
    );
end input_selection;

architecture structure of input_selection is
    signal selected_port: std_logic_vector(m-1 downto 0);
    begin
    first_mux: process(j,IN0,IN1,IN2,IN3,IN4,IN5,IN6,IN7)
    begin
    case j is
    when "000" => selected_port <= IN0;
    when "001" => selected_port <= IN1;
    when "110" => selected_port <= IN6;
    when others => selected_port <= IN7;
    end case;
    end process;
    second_mux: process(input_control,A,selected_port,result)
    begin
    case input_control is
    when "00" => to_reg <= A;
    when "01" => to_reg <= selected_port;
    when "10" => to_reg <= result;
    when others => to_reg <= (others => '0');
    end case;
    end process;
end structure;

