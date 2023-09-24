module CLK_GATE (
input      CLK,			/* Clock Signal */
input      CLK_EN,		/* Clock Enable */
output     GATED_CLK	/* Gated Clock signal */
);

/* Defining Internal Signals */
reg     Latch_Out ;

/* Latch Logic */
always @(CLK or CLK_EN)
 begin
  if(!CLK) 
   begin
    Latch_Out <= CLK_EN ;
   end
 end

/* AND Operation */
assign  GATED_CLK = CLK && Latch_Out ;

//The Following lines are for Synthesis 
/*
TLATNCAX4M  U0_TLATNCAX4M (

.E(CLK_EN),
.CK(CLK),
.ECK(GATED_CLK)
); 
*/

endmodule
