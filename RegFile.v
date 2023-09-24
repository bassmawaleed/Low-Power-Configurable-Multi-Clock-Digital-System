module RegFile #
(	parameter Address_Bus_Width = 4 , 
	parameter Write_Bus_Width = 8 , 
	parameter Read_Bus_Width = 8 , 
	parameter Reg_File_Width = 16
)
(
  input wire [Write_Bus_Width - 1 : 0] 	 WrData ,   	/* Write Data Bus */
  input wire [Address_Bus_Width - 1 : 0] Address,		/* Address bus */
  input wire    						 WrEn , 		/* Write Enable */
  input wire    						 RdEn ,			/* Read Enable */
  input wire    						 CLK ,			/* Clock Signal */
  input wire    						 RST ,			/* Active Low Reset */
  output reg [Read_Bus_Width - 1 : 0] 	 RdData , 		/* Read Data Bus */
  output reg 						  	 RdData_Valid , /* Read Data Valid */
  output wire [Read_Bus_Width - 1 : 0] REG0 ,			/* Register at Address 0x0 ,ALU Operand A */
  output wire [Read_Bus_Width - 1 : 0] REG1 ,			/* Register at Address 0x1, ALU Operand B */
  output wire [Read_Bus_Width - 1 : 0] REG2 ,			/* Register at Address 0x2, UART Config */
  output wire [Read_Bus_Width - 1 : 0] REG3 			/* Register at Address 0x3 , Div Ratio */
  );
  
reg [Write_Bus_Width - 1 : 0]  Reg_File [Reg_File_Width - 1 : 0] ;

/* Counter */
integer i ;

/* This flag is high during a read operation only */
//reg valid_flag ;

always @ (posedge CLK or negedge RST)
begin
  if ( !RST )
    begin
		for ( i = 0 ; i < Reg_File_Width ; i = i + 1 ) 
		begin
			  Reg_File[i] <= 0;	  
		end
		Reg_File[3] <= 32 ; /* Default Value for Division Ratio */
		
		/* UART Default Configuration */
		Reg_File[2][0] <= 1'b1 ;
		Reg_File[2][1] <= 1'b0 ;
		Reg_File[2][7:2] <= 32 ;
		
		/*For Command 4 */
		//Reg_File[1] <= 200 ;
		//Reg_File[0] <= 100 ;
		RdData <= 'b0 ;
		RdData_Valid <= 1'b0 ;
    end
  else
    begin
      if( WrEn && !RdEn)
        begin
          Reg_File[Address] <= WrData;
		  RdData_Valid <= 1'b0 ;
        end
      else if( !WrEn && RdEn )
        begin
          RdData <= Reg_File[Address];
		  RdData_Valid <= 1'b1 ;
        end
	  else
		RdData_Valid <= 1'b0 ;
    end
end

/* Reserved Registers Description */
assign REG0 = Reg_File[0] ; /* Operand A */
assign REG1 = Reg_File[1] ; /* Operand B */
assign REG2 = Reg_File[2] ; /* UART */
assign REG3 = Reg_File[3] ; /* Clock Divider */

/*
always @ (*)
begin
	if (valid_flag == 1 )
		RdData_Valid = 1 ;
	else
		RdData_Valid = 0 ;
	
end
*/

endmodule
