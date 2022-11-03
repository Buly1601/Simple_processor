package main_parameters is
constant m: 
	natural := 8; -- m-bit processor
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

architecture computation_resources_arch of computation_resources is
    begin
    process(f, left_in, right_in)
        begin
        if f = '0' then result <= left_in + right_in;
        else result <= left_in - right_in;
        end if;
    end process;
end computation_resources_arch;


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

architecture input_selection_arch of input_selection is
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
end input_selection_arch;


use work.main_parameters.all;
library ieee; 
use ieee.std_logic_1164.all;

entity output_selection is
    port (
    A, reg: in std_logic_vector(m-1 downto 0);
    clk, out_en, out_sel: in std_logic;
    i: in std_logic_vector(2 downto 0);
    OUT0, OUT1, OUT2, OUT3, OUT4, OUT5, OUT6, OUT7:
    out std_logic_vector(m-1 downto 0)
    );
end output_selection;

architecture output_selection_arch of output_selection is
    signal EN: std_logic_vector(0 to 7);
    signal DEC_OUT: std_logic_vector(0 to 7);
    signal to_ports: std_logic_vector(m-1 downto 0);
    begin
        decoder: process(i)
            begin
            case i is
                when "000" => DEC_OUT <= "10000000";
                when "001" => DEC_OUT <= "01000000";
                when "010" => DEC_OUT <= "00100000";
                when "110" => DEC_OUT <= "00000010";
                when others => DEC_OUT <= "00000001";
            end case;
            end process;
            
            and_gate: process(DEC_OUT, out_en)
            begin
                for i in 0 to 7 loop EN(i) <= DEC_OUT(i) AND out_en;
                end loop;
            end process;
            
            multiplexer: process(out_sel, A, reg)
            begin
                if out_sel = '0' then to_ports <= A;
                else to_ports <= reg; end if;
            end process;
            
            output_registers: process(clk)
            begin
                if clk'event and clk = '1' then
                    case EN is
                        when "10000000" => OUT0 <= to_ports;
                        when "01000000" => OUT1 <= to_ports;
                        when "00000001" => OUT7 <= to_ports;
                        when others => null;
                    end case;
                end if;
            end process;
end output_selection_arch;


use work.main_parameters.all;
library IEEE; use IEEE.std_logic_1164.all;

entity procesador is
    port(
        -- input ports of the entire system
        INPUT_DATA : in std_logic_vector(15 downto 0);
        IN0, IN1, IN2, IN3, IN4, IN5, IN6, IN7: in std_logic_vector(m-1 downto 0);
        instruction: in std_logic_vector(15 downto 0);
        clk, reset: in std_logic;
        OUT0, OUT1, OUT2, OUT3, OUT4, OUT5, OUT6, OUT7: out std_logic_vector(m-1 downto 0);
        number: inout std_logic_vector(7 downto 0)
    );
end procesador;

architecture structure of procesador is

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


	 begin
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
