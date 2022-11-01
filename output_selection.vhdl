package main_parameters is
    constant m: natural := 8; -- m-bit processor
end main_parameters;
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

architecture structure of output_selection is
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
end structure;