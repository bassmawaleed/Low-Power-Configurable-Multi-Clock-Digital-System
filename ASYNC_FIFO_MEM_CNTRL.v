module ASYNC_FIFO_MEM_CNTRL #(parameter data_width = 8 , parameter add_width = 4 , parameter fifo_depth = 8)(
	input wire 						 w_inc ,
	input wire 						 w_full ,
	input wire 						 w_clk ,
	input wire						 w_rst ,
	input wire [data_width - 1 : 0 ] w_data ,
	input wire  [add_width - 1 : 0 ] w_addr ,
	input wire  [add_width - 1 : 0 ] r_addr ,
	output reg [data_width - 1 : 0 ] r_data 
);

/* Internal Signals */
wire wclken ;

/* Loop Counter */
reg [ fifo_depth - 1 : 0] i ;

/* Register Memory Definition */
reg [data_width - 1 : 0] regmem [ fifo_depth - 1 : 0] ;

/* Write Operation Logic */
always @ (posedge w_clk or negedge w_rst)
begin
	if( !w_rst )
	begin
		for ( i = 0 ; i < fifo_depth ; i = i + 1 )
		begin
			regmem[i] <= 0 ;
		end
	end
	else
	begin
		if (wclken)
		begin
			regmem[w_addr] <= w_data ;
		end
	end
end

/* Read Operation Logic */
always @ (*)
begin
	r_data = regmem[r_addr];
end

assign wclken = w_inc && (!w_full);

endmodule

