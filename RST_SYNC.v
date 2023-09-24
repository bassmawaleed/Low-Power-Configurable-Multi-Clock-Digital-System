module RST_SYNC (
  input wire  RST,      /* Asynchronous reset */
  input wire  CLK,      /* Destination domain clock  */
  output reg  SYNC_RST  /* Synchronized Reset */
  );


/* Defining the internal signals */
reg intermediate_signal ;


/* First FF Logic */
always @ (posedge CLK or negedge RST)
begin
  if (!RST) /* Active Low Signal */
    intermediate_signal <= 0 ;
  else
    intermediate_signal <= 1 ; /* D should be equal to the inactive state of the RST Siganl */
end

/*Second FF Logic */
always @ (posedge CLK or negedge RST)
begin
  if(!RST)
    SYNC_RST <= 0;
  else
    SYNC_RST <= intermediate_signal ;
end

endmodule
