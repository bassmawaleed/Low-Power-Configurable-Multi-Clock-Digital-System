module SYS_CTRL 
#(	parameter alu_output_width = 16 , 
	parameter ALU_FUNC_WIDTH = 4 , 
	parameter addr_bus_width = 4 , 
	parameter Data_Width = 8 
  )
	(
	input wire							 CLK ,				/* Clock Signal */
	input wire							 RST ,				/* Active Low Reset */
	input wire [alu_output_width -1 : 0] ALU_OUT ,			/* ALU Result */
	input wire 							 OUT_VALID ,		/* ALU Result Valid */
	input wire 	  [Data_Width - 1 : 0]   RX_P_DATA ,		/* UART _RX Data */
	input wire 		 					 RX_D_VALID ,		/* RX Data Valid */
	input wire 	  [Data_Width - 1 : 0]   RD_DATA ,			/* Read Data Bus */
	input wire 		  					 RD_DATA_VALID, 	/* Read Data Valid */
	input wire 		  					 FIFO_FULL, 		/* Fifo Full flag */
	output reg							 ALU_EN ,			/* ALU Enable signal */
	output reg	[ALU_FUNC_WIDTH - 1 : 0] ALU_FUN ,			/* ALU Function signal */
	output reg							 CLK_EN ,			/* Clock gate enable */
	output reg [addr_bus_width - 1 : 0 ] Address ,			/* Address bus */
	output reg							 WrEn ,				/* Write Enable */
	output reg							 RdEn ,				/* Read Enable */
	output reg	  [Data_Width - 1 : 0]   WrData_Reg_File ,  /* Write Data Bus to RegFile */
	output reg	  [Data_Width - 1 : 0]   WrData_FIFO ,		/* Write Data Bus to RegFile */
	output reg							 WR_INC , 			/* Incrementing the FIFO Write Pointer */
	output reg							 clk_div_en 		/* Clock divider enable */
	);

parameter STATES_WIDTH = 5 ;

/* States definitions */
parameter [STATES_WIDTH - 1 : 0] IDLE = 'b0000 ;
parameter [STATES_WIDTH - 1 : 0] first_comm_first_frame = 'b0001 ;  /* Wait till address arrives */
parameter [STATES_WIDTH - 1 : 0] first_comm_second_frame = 'b0011 ; /* Address arrived . Wait for Data Arrival */
parameter [STATES_WIDTH - 1 : 0] first_comm_third_frame = 'b0010 ;  /* Put the Data on the write bus and go IDLE */

parameter [STATES_WIDTH - 1 : 0] second_comm_first_frame = 'b1000 ; /* Wait till address arrives */
parameter [STATES_WIDTH - 1 : 0] second_comm_second_frame = 'b1001; /* Address arrived . Go to Third State */
parameter [STATES_WIDTH - 1 : 0] second_comm_fifo_write = 'b1011 ;  /* If FIFO isn't full , perform the write operation . If FIFO is full , Wait for an empty location */

parameter [STATES_WIDTH - 1 : 0] third_comm_first_frame = 'b0100 ; 
parameter [STATES_WIDTH - 1 : 0] third_comm_second_frame = 'b0101 ; 
parameter [STATES_WIDTH - 1 : 0] third_comm_third_frame = 'b0111 ;
parameter [STATES_WIDTH - 1 : 0] third_comm_fourth_frame = 'b0110 ;
parameter [STATES_WIDTH - 1 : 0] third_comm_fifo_write = 'b1110 ;
parameter [STATES_WIDTH - 1 : 0] third_comm_fifo_write_2 = 'b1111 ;

parameter [STATES_WIDTH - 1 : 0] fourth_comm_first_frame = 'b1100 ; 


reg [STATES_WIDTH - 1 : 0] current_state ;
reg [STATES_WIDTH - 1 : 0] next_state ;
reg 	   [2:0]		   counter ; 								/* To count rising edges of data_valid */

/* Present state Logic */
always @ (posedge CLK or negedge RST)
begin
	if(!RST)
	begin
		current_state <= IDLE ;
	end
	else
	begin
		current_state <= next_state ;
	end
end


/* Next State Logic */
always @ (*)
begin
	case(current_state)
	IDLE : begin
			if (RX_D_VALID)
				case(RX_P_DATA)
				'hAA: begin	/* First Command Arrived */
						next_state = first_comm_first_frame ; 
					end
				'hBB: begin	/* Second Command Arrived */
						next_state = second_comm_first_frame ;
					end
				'hCC: begin	/* Third Command Arrived */
						next_state = third_comm_first_frame ;
					end
				'hDD: begin	/* Fourth Command Arrived */
						next_state = fourth_comm_first_frame ;
					end
				default: begin
						next_state = IDLE ;
					end
				
				endcase
			else
				next_state = IDLE ;
			
		end
		
	first_comm_first_frame : begin
							if(RX_D_VALID) /* Address arrived ! */
								next_state = first_comm_second_frame ;
							else
								next_state = first_comm_first_frame ;
						end
	first_comm_second_frame : begin
							if(RX_D_VALID) /* Data arrived ! */
								next_state = first_comm_third_frame ;
							else
								next_state = first_comm_second_frame ;
						end
	first_comm_third_frame : begin 
								next_state = IDLE ;
						end
	
	second_comm_first_frame : begin
								if(RX_D_VALID) /* Address arrived ! */
									next_state = second_comm_second_frame ;
								else
									next_state = second_comm_first_frame ;
						end
	second_comm_second_frame : begin
								if(RD_DATA_VALID)
									next_state = second_comm_fifo_write ;
								else
									next_state = second_comm_second_frame ;
								
						end
	second_comm_fifo_write : begin
								if (FIFO_FULL == 0)
								begin
									next_state = IDLE ;
								end
								else
								begin
									next_state = second_comm_fifo_write ;
								end
						end
	
	third_comm_first_frame : begin
							if(RX_D_VALID) /* ALU Operand A arrived ! */
								next_state = third_comm_second_frame ;
							else
								next_state = third_comm_first_frame ;
						end
	third_comm_second_frame : begin
							if(RX_D_VALID) /* ALU Operand B arrived ! */
								next_state = third_comm_third_frame ;
							else
								next_state = third_comm_second_frame ;
						end
	third_comm_third_frame : begin
							if(RX_D_VALID) /* ALU FUN arrived ! */
								next_state = third_comm_fourth_frame ;
							else
								next_state = third_comm_third_frame ;
						end
	third_comm_fourth_frame : begin
							if( OUT_VALID == 1 )
								next_state = third_comm_fifo_write ;
							else
								next_state = third_comm_fourth_frame ;
						end
	third_comm_fifo_write : begin
							if (FIFO_FULL == 0)
								begin
									next_state = third_comm_fifo_write_2 ;
								end
							else
								begin
									next_state = third_comm_fifo_write ;
								end
						end
	third_comm_fifo_write_2 : begin
							if (FIFO_FULL == 0)
								begin
									next_state = IDLE ;
								end
							else
								begin
									next_state = third_comm_fifo_write_2 ;
								end
						end
						
	fourth_comm_first_frame : begin
							if(RX_D_VALID) /* ALU FUN arrived ! */
								next_state = third_comm_fourth_frame ;
							else
								next_state = fourth_comm_first_frame ;
						end
	default : begin
				next_state = IDLE ; 
		end
	endcase
end

/* Outputs Logic */
always @ (*)
begin
			ALU_EN = 'b0;
			ALU_FUN = 'b0;		
			CLK_EN = 'b0;				
			WrEn = 'b0;			
			RdEn = 'b0;			
			WrData_Reg_File = 'b0;	
			WrData_FIFO = 'b0 ;
			WR_INC = 'b0;
			clk_div_en = 'b1;
			case(current_state)
			IDLE : begin
					ALU_EN = 'b0;		
					ALU_FUN = 'b0;		
					CLK_EN = 'b0;				
					WrEn = 'b0;			
					RdEn = 'b0;			
					WrData_Reg_File = 'b0;		
					WR_INC = 'b0;
					clk_div_en = 'b1;
				end
		
			first_comm_first_frame : begin
									ALU_EN = 'b0;		
									ALU_FUN = 'b0;		
									CLK_EN = 'b0;							
									RdEn = 'b0;			
									WrData_Reg_File = 'b0;		
									WR_INC = 'b0;
									WrEn = 'b0 ;
									/*
									if(RX_D_VALID)
									begin
										WrEn = 'b1 ;  Enable the Write Operation 
									end
									else
									begin
										WrEn = 'b0 ;  Disable the Write Operation 
									end
									*/
								end
			first_comm_second_frame : begin
									ALU_EN = 'b0;		
									ALU_FUN = 'b0;		
									CLK_EN = 'b0;							
									RdEn = 'b0;			
									WrData_Reg_File = 'b0;		
									WR_INC = 'b0;	
									WrEn = 'b0 ; /* Enable the Write Operation */
									
								end
			first_comm_third_frame : begin 
									
										ALU_EN = 'b0;		
										ALU_FUN = 'b0;		
										CLK_EN = 'b0;							
										RdEn = 'b0;					
										WR_INC = 'b0;	
										WrEn = 'b1 ; /* Enable the Write Operation */
										WrData_Reg_File = RX_P_DATA ;
										
								end
						
			second_comm_first_frame : begin
										ALU_EN = 'b0;		
										ALU_FUN = 'b0;		
										CLK_EN = 'b0;				
										WrEn = 'b0;			
										RdEn = 'b0;			
										WrData_Reg_File = 'b0;		
										WR_INC = 'b0;	
								end
			second_comm_second_frame : begin
										ALU_EN = 'b0;		
										ALU_FUN = 'b0;		
										CLK_EN = 'b0;				
										WrEn = 'b0;			
										RdEn = 'b1;			
										WrData_Reg_File = 'b0;		
										WR_INC = 'b0;		
								end
			second_comm_fifo_write : begin	
										if(FIFO_FULL == 0) /* Fifo isn't full */
										begin
											WrData_FIFO = RD_DATA ;
											WR_INC = 1'b1 ;
											RdEn = 'b0 ;
										end
										else
											begin
												WrData_FIFO = 0 ;
												WR_INC = 1'b0 ;
												RdEn = 'b1 ;
											end
								end
	
			third_comm_first_frame : begin
										ALU_EN = 'b0;
										ALU_FUN = 'b0;		
										CLK_EN = 'b0;						
										WrEn = 'b0;			
										RdEn = 'b0;			
										WrData_Reg_File = 'b0;	
										WrData_FIFO = 'b0 ;
										WR_INC = 'b0;
										clk_div_en = 'b1;
								end
			third_comm_second_frame : begin
										/* Write Op A in RegFile Location 0x0 */
										RdEn = 'b0;
										WrData_Reg_File = RX_P_DATA ;
										if(RX_D_VALID == 'b1) 
										begin
											WrEn = 'b0; /* Disable the Write Operation such that location 0x0 preserves its value */
											/* If this condition is omitted , Op A value will be overwritten by Op B */
										end
										else
										begin
											WrEn = 'b1 ;
										end
								end
			third_comm_third_frame : begin
										/* Write Op B in RegFile Location 0x1 */
										RdEn = 'b0;
										//CLK_EN = 'b1;
										if(Address == 'b1) 
										begin
											WrData_Reg_File = RX_P_DATA ;
										end
										else
										begin
											WrData_Reg_File = 0 ;
										end
										if(RX_D_VALID == 'b1) 
										begin
											WrEn = 'b0; /* Disable the Write Operation such that location 0x1 preserves its value */
											/* If this condition is omitted , Op B value will be overwritten by ALU FUN */
										end
										else
										begin
											WrEn = 'b1 ;
										end
										
								end
			third_comm_fourth_frame : begin
										ALU_EN = 'b1;
										ALU_FUN = RX_P_DATA[3:0];
										CLK_EN = 'b1;								
								end
			third_comm_fifo_write : begin
										ALU_EN = 'b0 ;
										CLK_EN = 'b0 ;
										if(FIFO_FULL == 0) /* Fifo isn't full */
										begin
											WrData_FIFO = ALU_OUT[7:0] ;
											WR_INC = 1'b1 ;
										end
										else
											begin
												WrData_FIFO = 0 ;
												WR_INC = 1'b0 ;
											end
								end
			third_comm_fifo_write_2 : begin
										if(FIFO_FULL == 0) /* Fifo isn't full */
										begin
											WrData_FIFO = ALU_OUT[15:8] ;
											WR_INC = 1'b1 ;
											ALU_EN = 'b0 ;
											CLK_EN = 'b0 ;
										end
										else
											begin
												WrData_FIFO = 0 ;
												WR_INC = 1'b0 ;
												ALU_EN = 'b0 ;
												CLK_EN = 'b0 ;
											end
								end
			fourth_comm_first_frame : begin
										ALU_EN = 'b0;
										ALU_FUN = 'b0;		
										CLK_EN = 'b0;				
										WrEn = 'b0;			
										RdEn = 'b0;			
										WrData_Reg_File = 'b0;	
										WrData_FIFO = 'b0 ;
										WR_INC = 'b0;
										clk_div_en = 'b1;
								end
	
			default : begin
						ALU_EN = 'b0;
						ALU_FUN = 'b0;		
						CLK_EN = 'b0;				
						WrEn = 'b0;			
						RdEn = 'b0;			
						WrData_Reg_File = 'b0;	
						WrData_FIFO = 'b0 ;
						WR_INC = 'b0;
						clk_div_en = 'b1;
					end
	endcase 
end

/* To handle the address */
always @ (posedge CLK or negedge RST)
begin
	if (!RST)
		Address <= 0 ;
	else
	begin
		if ( ((next_state == first_comm_second_frame) && (counter == 1)) || ((next_state == second_comm_second_frame) && (counter == 0)))
			Address <= RX_P_DATA ;
		if (next_state == third_comm_second_frame)
			Address <= 'b0 ; 
		if ((next_state == third_comm_third_frame))
			Address <= 'b1 ;
	end

end

/* Counter Logic */
always @ (posedge CLK or negedge RST)
begin
	if (!RST)
		counter <= 0 ;
	else
	begin
		if ( RX_D_VALID )
			counter <= counter + 1 ;
		
		if(current_state == IDLE)
			counter <= 0 ;
	end

end

endmodule 
