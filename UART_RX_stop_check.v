module UART_RX_stop_check (
  input wire sampled_bit ,
  input wire stp_chk_en ,
  output reg stp_err
  );


always@(*)
begin
  if(stp_chk_en == 1)
    begin
      if (sampled_bit == 1) 
        begin /* Stop Bit */
          stp_err = 0 ;
        end
      else
        begin
          stp_err = 1 ;
        end
      end
  else
    begin
      stp_err = 0 ;
    end
end



endmodule
