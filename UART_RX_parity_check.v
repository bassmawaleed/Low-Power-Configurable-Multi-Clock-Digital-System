module UART_RX_parity_check (
  input wire PAR_TYPE ,
  input wire [7:0] P_DATA ,
  input wire par_chk_en ,
  input wire sampled_bit ,
  output reg par_err 
);

reg       actual_parity_bit ;
reg       expected_parity_bit;


/* Calculating the Parity */
/* Parity Type : 0 --> Even Parity , 1--> Odd Parity */
always @ (*)
begin
  if(par_chk_en == 1 )
    begin
        actual_parity_bit = sampled_bit ;
        if(PAR_TYPE == 0) /* Even Parity */
          begin
            if( ^P_DATA == 0) /* data has even number of 1's*/
              expected_parity_bit = 0 ;
            else
              expected_parity_bit = 1;
          end
        else /* Odd Parity */
          begin
            if( ^P_DATA == 0) /* data has even number of 1's*/
              expected_parity_bit = 1 ;
            else
              expected_parity_bit = 0;
          end
      
        if (expected_parity_bit == actual_parity_bit)
            par_err = 0 ;
        else
            par_err = 1 ;
  end
  else
    begin
      actual_parity_bit = 0 ;
      expected_parity_bit = 0;
      par_err = 0 ;
    end
end


endmodule
