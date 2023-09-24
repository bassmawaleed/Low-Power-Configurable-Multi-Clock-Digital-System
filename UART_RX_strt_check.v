module UART_RX_strt_check (
  input wire sampled_bit ,
  input wire strt_chk_en ,
  output reg strt_glitch
  );

always @ (*)
begin
  if(strt_chk_en == 1)
    begin
      if (sampled_bit == 0) 
        begin /* Start Bit */
          strt_glitch = 0 ;
        end
      else
        begin
          strt_glitch = 1 ;
        end
      end
  else
    begin
      strt_glitch = 1 ;
    end
end

endmodule
