library ieee; use ieee.std_logic_1164.all;
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


architecture structure of register_bank is
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
end structure;