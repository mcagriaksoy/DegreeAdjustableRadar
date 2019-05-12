    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    entity pwm_servo is
    	Generic(
    		count_max : integer := 1000000;
    		duty_max : integer := 100000;
    		duty_min : integer := 50000;
    		duty_delta : integer := 200
    		);
      Port( CLK : in STD_LOGIC;
    	PWM : out std_logic
          );
    end pwm_servo;
     
    architecture Behavioral of pwm_servo is
     
     signal counter: integer range 0 to count_max := 0;
     signal duty : integer range duty_min to duty_max := duty_min;
     signal count_max : integer := 1000000;
    signal 		duty_max : integer := 100000;
    signal 		duty_min : integer := 50000;
    	signal 	duty_delta : integer := 200
    begin
      prescaler: process(clk)
       variable direction_up : boolean := true;
    begin
    	if rising_edge(clk) then
    	  if counter < count_max then
    		counter <= counter + 1;
    	  else
    	   if direction_up then
    		if duty < duty_max then
    		  duty <= duty + duty_delta;
    		else
    		  direction_up := false;
    		end if;
    		else
    		  if duty > duty_min then
    		    duty <= duty - duty_delta;
    		  else
    		  direction_up := true;
    	     end if;
              end if;
             counter <= 0;
            end if;
           end if;
      end process;
          pwm_s: process(clk)
       begin
    	if counter < duty then
    		pwm <= '1';
    	else
    		pwm <= '0';
    	end if;
    end process;
    end Behavioral;