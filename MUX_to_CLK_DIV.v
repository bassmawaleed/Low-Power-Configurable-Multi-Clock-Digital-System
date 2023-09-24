module MUX_to_CLK_DIV (
input wire 		[5:0] 		   prescaler ,
output reg 		[7 : 0]  	   i_div_ratio 
);

always @(*)
begin
	case(prescaler)
	'b100000 : begin				/* prescaler = 32 */
				i_div_ratio = 1 ;
			end
	'b010000 : begin				/* prescaler = 16 */
				i_div_ratio = 2 ;
			end
	'b001000 : begin				/* prescaler = 8 */
				i_div_ratio = 4 ;
			end		
	'b000100 : begin				/* prescaler = 4 */
				i_div_ratio = 8 ;
			end	
	default : begin
				i_div_ratio = 1 ;
			end
			
	endcase
end
endmodule 