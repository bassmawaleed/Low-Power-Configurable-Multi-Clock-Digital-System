module ASYNC_FIFO_RD #(parameter ptr_width = 4 , parameter add_width = 3)(
	input wire 						r_inc ,
	input wire						r_clk ,
	input wire						rrst_n ,
	input wire [ptr_width - 1 : 0]	rq2_wptr ,
	output reg						rempty,
	output wire [add_width - 1 : 0] raddr ,
	output reg [ptr_width - 1 : 0]	gray_rptr	
);


reg [ptr_width - 1 : 0]	rptr ;

always @ (posedge r_clk or negedge rrst_n)
begin
	if (!rrst_n)
		begin
			rptr <= 0 ;
		end
	else
		begin
			if (r_inc && !rempty)
				begin
					rptr <= rptr + 1 ;
				end
		end
end

/* Read Address */
assign raddr = rptr[ ptr_width - 2 : 0 ] ;

always @ (*)
begin
/* Empty Flag Logic */
	if (gray_rptr == rq2_wptr)
		begin
			rempty = 1'b1 ;
		end
	else
		begin
			rempty = 1'b0 ;
		end
end

/* Binary To Gray Logic */
always @ (posedge r_clk or negedge rrst_n)
begin
	if (!rrst_n)
		begin
			gray_rptr <= 0 ;
		end
	else
		begin
			case (rptr)
				'b0000 : gray_rptr <= 'b0000 ;
				'b0001 : gray_rptr <= 'b0001 ;
				'b0010 : gray_rptr <= 'b0011 ;
				'b0011 : gray_rptr <= 'b0010 ;
				'b0100 : gray_rptr <= 'b0110 ;
				'b0101 : gray_rptr <= 'b0111 ;
				'b0110 : gray_rptr <= 'b0101 ;
				'b0111 : gray_rptr <= 'b0100 ;
				'b1000 : gray_rptr <= 'b1100 ;
				'b1001 : gray_rptr <= 'b1101 ;
				'b1010 : gray_rptr <= 'b1111 ;
				'b1011 : gray_rptr <= 'b1110 ;
				'b1100 : gray_rptr <= 'b1010 ;
				'b1101 : gray_rptr <= 'b1011 ;
				'b1110 : gray_rptr <= 'b1001 ;
				'b1111 : gray_rptr <= 'b1000 ;
			endcase
		end
	
end

endmodule
