
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
	port (
		  i_clk : in std_logic; 
		  i_start : in std_logic; 
		  i_rst : in std_logic; 
		  i_data : in std_logic_vector(7 downto 0);  
		  o_address : out std_logic_vector(15 downto 0); 
		  o_done : out std_logic; 
		  o_en  : out std_logic; 
		  o_we : out std_logic; 
		  o_data : out std_logic_vector (7 downto 0)
		  ); 
		  
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

	type type_states is (rst, read_input_addr, find_wz_base, get_wz_base, scan_wz, not_in_wz, in_wz, set_output, final_state);
	
	signal curr_state : type_states;
	signal wz_bit : std_logic;
	signal addr : std_logic_vector(6 downto 0);
	signal wz_base : std_logic_vector(6 downto 0);
	signal wz_num : std_logic_vector(2 downto 0);
	signal wz_offset : std_logic_vector(3 downto 0);
	signal wz_offset_binary : std_logic_vector(1 downto 0);

    begin
    
    processo: process(i_clk,i_rst)
    variable i: integer := 0;
    
 
	begin 
	
		if i_rst = '1'  then
		  	curr_state <= rst;
		  	
		else if (i_clk'event and i_clk='0') then   
			
				case curr_state is 
				
					when rst =>
	                    i := 0;
						o_address <= "0000000000000000";
						o_done <= '0';
						o_en <= '0';
						o_we <= '0';
						o_data <= "00000000";
						addr <= "0000000";
				    	wz_offset_binary <= "00";
				    	wz_offset <= "0001";
						wz_base <=	"0000000";
						wz_num <= "000";
						wz_bit <= '0';		
						
						if i_start = '1' then
					        o_address <= "0000000000001000";	
						    o_en <= '1';       
							curr_state <= read_input_addr;				
					    end if;
					

					when read_input_addr =>
					      addr <= i_data (6 downto 0);    
					      curr_state <= find_wz_base;
					
					
					when find_wz_base =>		     			                               
                          o_address <= std_logic_vector(to_unsigned(i,16));
                          curr_state <= get_wz_base;
                     		
                     					
					when get_wz_base =>	  
                       
						if i < 8 then	
				             wz_base <= i_data (6 downto 0) ;       
							 curr_state <= scan_wz;   
							         					                            						
						else
							o_we <= '1';
							o_address <= "0000000000001001";
							
							curr_state <= not_in_wz;   										
						end if;
						                        
				                                         
				    when scan_wz => 
  	                    
	                    if addr >= wz_base and std_logic_vector( unsigned(addr) - unsigned(wz_base)) < "0000100"  then
	                          
				             wz_offset_binary <= std_logic_vector(unsigned( addr(1 downto 0)) - unsigned(wz_base(1 downto 0) )); 
                             wz_num <= std_logic_vector(to_unsigned(i,3));  
 
				             curr_state <= in_wz; 
                     	                
                        else
                             i := i+1;  
                             curr_state <= find_wz_base;               
		     			end if;
							
										
					when not_in_wz => 
					
						wz_bit <= '0';
				        o_data <= wz_bit & addr;
					    curr_state <= final_state;
					    
					    
					when in_wz =>	
					  
					    wz_offset <= std_logic_vector( shift_left( unsigned(wz_offset),to_integer(unsigned(wz_offset_binary)) ) );   
				        o_we <= '1';
				       	wz_bit <= '1';
				        o_address <= "0000000000001001";
                        curr_state <= set_output;
                         
                       
				    when set_output =>		
					
				        o_data <= wz_bit & wz_num & wz_offset;			        
				        curr_state <= final_state;
				
					when final_state =>
					
						if i_start = '0' then
							o_done <= '0';
							curr_state <= rst;
									
						else
							o_done <= '1';
							o_we <= '0';							
						end if;
							
				end case;					
			end if;
		end if;	
	end process;
end Behavioral;
