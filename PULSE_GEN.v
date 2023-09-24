module PULSE_GEN (
input wire RST ,		/* Active Low Reset */
input wire CLK , 		/* Clock Signal */
input wire LVL_SIG ,	/* Level signal */
output reg PULSE_SIG 	/* Pulse signal */
);

/* Internal Signals */
reg pulse_generator_ff_output ;

/* Pulse Generator Sequential Cell Logic  */
always @ (posedge CLK or negedge RST)
begin
  if (!RST)
    pulse_generator_ff_output <= 0 ;
  else
    begin  
      pulse_generator_ff_output <= LVL_SIG ;
    end
end

/* Pulse Generator Combinational Cell Logic  */
always @ (*)
begin
  PULSE_SIG =  LVL_SIG && (! pulse_generator_ff_output) ;
end

endmodule 