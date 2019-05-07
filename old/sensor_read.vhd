----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.04.2019 16:31:44
-- Design Name: 
-- Module Name: sensor_read - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sensor_read is
generic (
        LED_WIDTH	: integer	:= 8
		);
	port(
	    S_AXI_ACLK    : in std_logic;
		S_AXI_ARESETN : in std_logic;
		S_AXI_WDATA   : in std_logic_vector(31 downto 0);
        slv_reg_wren  : in std_logic;
        slv_reg_rden  : in std_logic;
        axi_awaddr    : in std_logic_vector(1 downto 0);
        axi_araddr    : in std_logic_vector(1 downto 0);
        sonar_echo    : in STD_LOGIC;
        output        : out std_logic_vector(7 downto 0);
		sonar_trig    : out STD_LOGIC	
		);
end sensor_read;

architecture Behavioral of sensor_read is
    signal count            : unsigned(16 downto 0) := (others => '0');
    signal centimeters      : unsigned(15 downto 0) := (others => '0');
    signal centimeters_ones : unsigned(3 downto 0)  := (others => '0');
    signal centimeters_tens : unsigned(3 downto 0)  := (others => '0');
    signal output_uns : unsigned(7 downto 0)  := (others => '0');
    signal echo_last        : std_logic := '0';
    signal echo_synced      : std_logic := '0';
    signal echo_unsynced    : std_logic := '0';
    signal waiting          : std_logic := '0';
     

begin
process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if waiting = '0' then
                if count = 1000 then -- Assumes 100MHz                 
                   sonar_trig <= '0';
                   waiting    <= '1';
                   count       <= (others => '0');
                else
                   sonar_trig <= '1';
                   count <= count+1;
                end if;
            elsif echo_last = '0' and echo_synced = '1' then
                -- Seen rising edge - start count
                count       <= (others => '0');
                centimeters <= (others => '0');
                centimeters_ones <= (others => '0');
                centimeters_tens <= (others => '0');			
            elsif echo_last = '1' and echo_synced = '0' then
                -- Seen falling edge, so capture count
                output_uns <= centimeters(7 downto 0);
                				
            elsif count = 2900*2 -1 then
                -- advance the counter
                if centimeters_ones = 9 then
                    centimeters_ones <= (others => '0');
                    centimeters_tens <= centimeters_tens + 1;
                else
                    centimeters_ones <= centimeters_ones + 1;
                end if;		
                centimeters <= centimeters + 1;
                count <= (others => '0');		
                if centimeters = 3448 then
                    -- time out - send another pulse
                    waiting <= '0';
                end if;
            else
                count <= count + 1; 				
            end if;
            
            echo_last     <= echo_synced;
            echo_synced   <= echo_unsynced;
            echo_unsynced <= sonar_echo;
        end if;
       
end process;

process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      output  <= (others => '0');
	    else
	      if (slv_reg_wren = '1' and ((axi_awaddr = "00") or (axi_awaddr = "01")or (axi_awaddr = "10")or (axi_awaddr = "11"))) then
	        -- When slv_reg0 or slv_reg1 is written by the processor then LED will display the least significant 8-bits
	         output  <= S_AXI_WDATA(LED_WIDTH-1 downto 0);  -- wdata is written to the LED_out data
	      end if; 
	      if  (slv_reg_rden = '1' and (axi_araddr = "11")) then
	          output <= std_logic_vector(output_uns);  -- the result of the operation is written to the LEDs
	      end if; 
	    end if;
	  end if;
	end process;		


end Behavioral;
