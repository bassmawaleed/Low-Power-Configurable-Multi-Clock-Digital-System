module UART_TX_Parity_Calc #(parameter data_width = 8)(
  input            				  CLK,
  input wire [data_width - 1 : 0] P_DATA , 
  input wire       				  PAR_TYP ,
  input wire       				  parity_read  ,
  output reg       				  par_bit
  );

reg [data_width - 1 : 0] Data;

always @ (posedge CLK)
begin
        if( parity_read == 1 )
        begin
          Data <= P_DATA;
        end
end



always @ (*)
begin
      if(PAR_TYP == 1'b0) //Even Parity
        begin
          if ( (^Data)  == 0) /* Number of ones is an even number . So , Even Parity = 0*/
            par_bit = 1'b0;
          else /* Number of ones is an odd number . So , Even Parity = 1*/
            par_bit = 1'b1;
        end
      else //Odd Parity
        begin
          if ( (^Data) == 0) /* Number of ones is an even number. So , Odd Parity = 1 */
            par_bit = 1'b1;
          else /* Number of ones is an odd number. So , Odd Parity = 0 */
            par_bit = 1'b0;
        end
end

endmodule

