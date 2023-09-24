module Data_Sync # ( 
     parameter NUM_STAGES = 2 ,
	 parameter DATA_WIDTH = 8 
)(
input    wire                       dest_clk,		/* Destination Clock Signal */
input    wire                       dest_rst,		/* Destination Active Low Reset*/
input    wire     [DATA_WIDTH-1:0]  unsync_bus,		/* Unsynchronized bus */
input    wire                       bus_enable,		/* Bus enable signal */
output   reg      [DATA_WIDTH-1:0]  sync_bus,		/* synchronized bus */
output   reg                        enable_pulse_d	/* enable pulse signal */
);

/* Internal Signals Definition*/
reg   [NUM_STAGES-1:0]    sync_reg;
reg                       enable_flop ;
					 
wire                      enable_pulse ;

wire  [DATA_WIDTH-1:0]     sync_bus_comb ;
					 
//----------------- Multi flop synchronizer --------------

always @(posedge dest_clk or negedge dest_rst)
 begin
  if(!dest_rst)      // active low
   begin
    sync_reg <= 'b0 ;
   end
  else
   begin
    sync_reg <= {sync_reg[NUM_STAGES-2:0],bus_enable};
   end  
 end
 

//----------------- pulse generator --------------------

always @(posedge dest_clk or negedge dest_rst)
 begin
  if(!dest_rst)      // active low
   begin
    enable_flop <= 1'b0 ;	
   end
  else
   begin
    enable_flop <= sync_reg[NUM_STAGES-1] ;
   end  
 end

 
assign enable_pulse = sync_reg[NUM_STAGES-1] && !enable_flop ;


//----------------- multiplexing --------------------

assign sync_bus_comb =  enable_pulse ? unsync_bus : sync_bus ;  


//----------- destination domain flop ---------------

always @(posedge dest_clk or negedge dest_rst)
 begin
  if(!dest_rst)      // active low
   begin
    sync_bus <= 'b0 ;	
   end
  else
   begin
    sync_bus <= sync_bus_comb ;
   end  
 end
 
//--------------- delay generated pulse ------------

always @(posedge dest_clk or negedge dest_rst)
 begin
  if(!dest_rst)      // active low
   begin
    enable_pulse_d <= 1'b0 ;	
   end
  else
   begin
    enable_pulse_d <= enable_pulse ;
   end  
 end
 

endmodule
