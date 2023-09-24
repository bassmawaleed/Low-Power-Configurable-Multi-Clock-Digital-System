module ASYNC_FIFO_WR #(parameter ptr_width = 4 , parameter add_width = 3)(
	input wire 						w_inc ,
	input wire						w_clk ,
	input wire						wrst_n ,
	input wire [ptr_width - 1 : 0]	wq2_rptr ,
	output reg						wfull,
	output wire [add_width - 1 : 0] waddr ,
	output reg [ptr_width - 1 : 0]	gray_wptr
);

reg [ptr_width - 1 : 0]	wptr ;

/* Operation */
always @ (posedge w_clk or negedge wrst_n)
begin
	if (!wrst_n)
	begin
		wptr <= 'b0 ;
	end
	else
		begin
			if (w_inc && !wfull)
			begin
				wptr <= wptr + 1 ;
			end
			
		end
end

/* Write address logic */
assign waddr = wptr[ ptr_width - 2 : 0];

always @ (*)
begin
	/* Full Flag Logic */
		if( (gray_wptr[ptr_width - 1] != wq2_rptr[ptr_width - 1] ) && (gray_wptr[ptr_width - 2] != wq2_rptr[ptr_width - 2] ) && ((gray_wptr[ptr_width - 3 : 0] == wq2_rptr[ptr_width - 3 : 0] )) )
			begin
				wfull = 1'b1 ;
			end
		else
			begin
				wfull = 1'b0 ;
			end

end


/* Binary To Gray Logic */
always @ (posedge w_clk or negedge wrst_n)
begin
	
	if (!wrst_n)
		begin
			gray_wptr <= 0 ;
		end
	else
		begin
			case (wptr)
				'b0000 : gray_wptr <= 'b0000 ;
				'b0001 : gray_wptr <= 'b0001 ;
				'b0010 : gray_wptr <= 'b0011 ;
				'b0011 : gray_wptr <= 'b0010 ;
				'b0100 : gray_wptr <= 'b0110 ;
				'b0101 : gray_wptr <= 'b0111 ;
				'b0110 : gray_wptr <= 'b0101 ;
				'b0111 : gray_wptr <= 'b0100 ;
				'b1000 : gray_wptr <= 'b1100 ;
				'b1001 : gray_wptr <= 'b1101 ;
				'b1010 : gray_wptr <= 'b1111 ;
				'b1011 : gray_wptr <= 'b1110 ;
				'b1100 : gray_wptr <= 'b1010 ;
				'b1101 : gray_wptr <= 'b1011 ;
				'b1110 : gray_wptr <= 'b1001 ;
				'b1111 : gray_wptr <= 'b1000 ;
	endcase
		end
end


endmodule

