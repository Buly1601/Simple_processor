library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
package main_parameters is
constant m: 
	natural := 8; -- m-bit processor
    constant zero: std_logic_vector(m-1 downto 0) := conv_std_logic_vector(0, m);
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


library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.main_parameters.all;

entity go_to is
    port (
    N, data: in std_logic_vector(m-1 downto 0);
    clk, reset: in std_logic;
    numb_sel: in std_logic_vector(3 downto 0);
    number: inout std_logic_vector(m-1 downto 0)
    );
end go_to;


architecture go_to_arch of go_to is
    signal pos, neg, load: std_logic;
    begin
    sign_computation: process(data)
    begin
    if data(m-1) = '1' then pos <= '0'; neg <= '1';
    elsif data = zero then pos <= '0'; neg <= '0';
    else pos <= '1'; neg <= '0'; end if;
    end process;
    load_condition: process(numb_sel, pos, neg)
    begin
        case numb_sel is
        when "1110" => load <= '1';
        when "1100" => load <= pos;
        when "1101" => load <= neg;
        when others => load <= '0';
        end case;
    end process;
    programmable_counter: process(clk, reset)
    begin
        if reset = '1' then number <= zero;
        elsif clk'event and clk = '1' then
        if load = '1' then number <= N;
        else number <= number + 1; end if;
        end if;
    end process;
end go_to_arch;


library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.main_parameters.all;

entity register_bank is
    port (
    reg_in: in std_logic_vector(m-1 downto 0);
    clk, write_reg: in std_logic;
    i, j, k: in std_logic_vector(3 downto 0);
    left_out, right_out:
    out std_logic_vector(m-1 downto 0)
    );
end register_bank;


architecture register_bank_arch of register_bank is
    type memory is array (0 to 15) of
    std_logic_vector(m-1 downto 0);
    signal X: memory;
    signal EN: std_logic_vector(0 to 15);
    begin
        decoder: process(k, write_reg)
        begin
            for i in 0 to 15 loop
            if i < conv_integer(k) then EN(i) <= '0';
            elsif i = conv_integer(k) then EN(i) <= write_reg;
            else EN(i) <= '0'; end if;
            end loop;
        end process;
        bank_registers: process(clk)
            begin
            if clk'event and clk = '1' then
            for i in 0 to 15 loop
            if EN(i) = '1' then X(i) <= reg_in;
            end if;
            end loop;
            end if;
        end process;
        first_multiplexer: process(i, X)
        begin
            case i is
            when "0000" => left_out <= X(0);
            when "0001" => left_out <= X(1);
            when "0010" => left_out <= X(2);
            when "0011" => left_out <= X(3);
            when "0100" => left_out <= X(4);
            when "0101" => left_out <= X(5);
            when "0110" => left_out <= X(6);
            when "0111" => left_out <= X(7);
            when "1000" => left_out <= X(8);
            when "1001" => left_out <= X(9);
            when "1010" => left_out <= X(10);
            when "1011" => left_out <= X(11);
            when "1100" => left_out <= X(12);
            when "1101" => left_out <= X(13);
            when "1110" => left_out <= X(14);
            when others => left_out <= X(15);
            end case;
        end process;
        second_multiplexer: process(j, X)
        begin
            case j is
            when "0000" => right_out <= X(0);
            when "1110" => right_out <= X(14);
            when others => right_out <= X(15);
            end case;
        end process;
end register_bank_arch;

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
    
    -- register bank
    component register_bank is
        port (
            reg_in: in std_logic_vector(m-1 downto 0);
            clk, write_reg: in std_logic;
            i, j, k: in std_logic_vector(3 downto 0);
            left_out, right_out:
            out std_logic_vector(m-1 downto 0)
        );
    end component;

    -- go to
    component go_to is
        port (
            N, data: in std_logic_vector(m-1 downto 0);
            clk, reset: in std_logic;
            numb_sel: in std_logic_vector(3 downto 0);
            number: inout std_logic_vector(m-1 downto 0)
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

    register_bank_comp : register_bank
        port map (reg_in => reg_in, clk => clk,
        write_reg => write_reg,
        i => instruction(11 downto 8),
        j => instruction(7 downto 4),
        k => instruction(3 downto 0), left_out => left_out,
        right_out => right_out);
    
    go_to_comp : go_to
        port map (N => instruction(7 downto 0), data => left_out,
        clk => clk, reset => reset,
        numb_sel => instruction(15 downto 12),
        number => number);
    
    -- boolean equations
    out_en <= instruction(15) AND NOT(instruction(14));
    write_reg <= NOT(instruction(15));

end structure;
