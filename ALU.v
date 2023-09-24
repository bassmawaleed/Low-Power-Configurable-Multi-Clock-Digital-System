module ALU 
#(
  parameter Data_Width = 8 ,
  parameter ALU_FUNCTION_WIDTH = 4 , 
  parameter output_width = 16 
 )
 (
  input wire 	[Data_Width - 1 : 0] 		A ,		/* Operand A */
  input wire 	[Data_Width - 1 : 0] 		B ,		/* Operand B */
  input wire [ALU_FUNCTION_WIDTH - 1 : 0] ALU_FUN , /* ALU Function */
  input wire        					  CLK , 	/* Clock Signal */
  input wire        					  RST , 	/* RST Signal */
  input wire							  Enable ,  /* ALU Enable */
  output reg [output_width - 1 : 0] ALU_OUT ,		/* ALU Result */
  output reg        Out_Valid 						/* Result Valid */
  );


always@(posedge CLK or negedge RST)
begin
	if(!RST)
	begin
		ALU_OUT <= 0;
        Out_Valid <= 1'b0 ;
	end
	else
	begin
		  if(Enable == 1)
		  begin
		  case(ALU_FUN)
			4'b0000 : begin
						ALU_OUT <= A + B ;
						Out_Valid <= 1'b1 ;
					  end
			4'b0001 : begin
						ALU_OUT <= A - B ;
						Out_Valid <= 1'b1 ;
					  end    
			4'b0010 : begin
						ALU_OUT <= A * B ;
						Out_Valid <= 1'b1 ;
					  end
			4'b0011 : begin
						ALU_OUT <= A / B ;
						Out_Valid <= 1'b1 ;
					  end
			4'b0100 : begin
						ALU_OUT <= A & B ;
						Out_Valid <= 1'b1 ;
					  end
			4'b0101 : begin
						ALU_OUT <= A | B ;
						Out_Valid <= 1'b1 ;
					  end
			4'b0110 : begin
						ALU_OUT <= ~(A & B) ;
						Out_Valid <= 1'b1 ;
					  end
			4'b0111 : begin
						ALU_OUT <= ~( A | B) ;
						Out_Valid <= 1'b1 ;
					  end
			4'b1000 : begin
						ALU_OUT <= A ^ B ;
						Out_Valid <= 1'b1 ;
					  end
			4'b1001 : begin
						ALU_OUT <= A ~^ B ;
						Out_Valid <= 1'b1 ;
					  end
			4'b1010 : begin
						if ( A == B )
						  begin
							ALU_OUT <= 16'b1;
						  end
						else
						  begin
							ALU_OUT <= 16'b0;
						  end 
						Out_Valid <= 1'b1 ;
					  end
			4'b1011 : begin
						if ( A > B )
						  begin
							ALU_OUT <= 16'b10;
						  end
						else
						  begin
							ALU_OUT <= 16'b0;
						  end 
						Out_Valid <= 1'b1 ;
						end
		  
			4'b1100 : begin
						if ( A < B )
						  begin
							ALU_OUT <= 16'b11;
						  end
						else
						  begin
							ALU_OUT <= 16'b0;
						  end 
						Out_Valid <= 1'b1 ;
						end
		  
			4'b1101 : begin
							ALU_OUT <= A >> 1 ;
							Out_Valid <= 1'b1 ;
						end
			4'b1110 : begin
							ALU_OUT <= A << 1 ;
							Out_Valid <= 1'b1 ;
						end
			default : begin
							ALU_OUT <= 16'b0 ;
							Out_Valid <= 1'b0 ;
						end
		  endcase
		  end  
		  else
			Out_Valid <= 1'b0 ;
	end
end
endmodule