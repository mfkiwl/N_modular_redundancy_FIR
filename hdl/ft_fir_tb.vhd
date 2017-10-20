library ieee, modelsim_lib;
use ieee.std_logic_1164.all;
use modelsim_lib.util.all;
use ieee.numeric_std.all;
use work.util_pkg.all;

entity ft_fir_tb is
    generic(data_w : natural := 24;
        order  : natural := 10
        );
end ft_fir_tb;

architecture Behavioral of ft_fir_tb is
	
	signal     clk 			: std_logic := '1';
    signal     we_in          : std_logic;
    signal     coef_addr_in : std_logic_vector(log2c(order) - 1 downto 0);
    signal     coef_in         : std_logic_vector(data_w - 1 downto 0);
    signal     u_in           : std_logic_vector(data_w - 1 downto 0);
    signal     y_out           : std_logic_vector(data_w - 1 downto 0);
    type       data_reg is array (natural range <>) of std_logic_vector(data_w - 1 downto 0);
    signal coef_reg : data_reg(order downto 0);
    signal data_in_reg : data_reg(order-1 downto 0);
    signal expected_data : data_reg(order-1 downto 0);

begin

DUT : entity work.fault_tolerant_fir
	  	generic map(
   		 		order 	=> order,
    			data_w 	=> data_w)
		port map(
				clk 		 => clk,
				we_in  		 => we_in,
				coef_addr_in => coef_addr_in,
				coef_in 	 => coef_in,
				u_in		 => u_in,
				y_out 		 => y_out
				);
	coef_reg <= ("000000011111101100010011",
                 "111111110000000010111111",
                 "111101111110101100011101",
                 "000000100000110110001000",
                 "001001100110111110000110",
                 "001111010011100000000101",
                 "001001100110111110000110",
                 "000000100000110110001000",
                 "111101111110101100011101",
                 "111111110000000010111111",
                 "000000011111101100010011");

    data_in_reg <= ("111111111100110110010110",
                    "000000000000000000000000",
                    "111111111110011011001011",
                    "111111100110000000011001",
                    "000000000111111000001000",
                    "111111110000001111110000",
                    "111111101000010111101000",
                    "000000001001011100111101",
                    "111111011100100011011101",
                    "000000001001011100111101");

    expected_data <= (  "111111111111111100111000",
                        "000000000000000001100101",
                        "000000000000001011001011",
                        "111111111111100011110100",
                        "111111111111011110100101",
                        "111111111111110011011101",
                        "111111111101011011000111",
                        "111111111000110101111001",
                        "111111110110010001101011",
                        "111111110110101011010110");

     clk <= not clk after 10 ns;

FaultSelProc: process
  type fault_type is (_NONE, _ERROR, REG_S_SA0, REG_S_SA0, MUL_OUT_SA0, MUL_OUT_SA1, MAC_OUT_SA0, MAC_OUT_SA1);
  signal fault_sel: fault_type;
  signal mac_sel: std_logic_vector(2 downto 0);
  signal fir_sel: std_logic_vector(2 downto 0);
begin
  fault_sel <= _NONE;
  mac_sel <= "000";
  fir_sel <= "000";
  wait for 200 ns;

  fault_sel <= REG_S_SA0;
  wait for 200 ns;

  fault_sel <= REG_S_SA1;
  wait for 200 ns;

  fault_sel <= MUL_OUT_SA0;
  wait for 200 ns;

  fault_sel <= MUL_OUT_SA1;
  wait for 200 ns;

  fault_sel <= MAC_OUT_SA0;
  wait for 200 ns;

  fault_sel <= MAC_OUT_SA1;
  wait for 200 ns;

end process FaultSelProc;

     WaveGenProc: process
     begin
       wait until clk = '1';
       for i in 0 to order loop
         we_in <= '1';
         coef_addr_in <= std_logic_vector(to_unsigned(i, log2c(order)));
         coef_in <= coef_reg(i);
         wait until clk = '1';
       end loop;
       for i in 0 to order -1 loop
         u_in <= data_in_reg(i);
         wait until clk = '1';
       end loop;
     end process WaveGenProc;
end Behavioral;
