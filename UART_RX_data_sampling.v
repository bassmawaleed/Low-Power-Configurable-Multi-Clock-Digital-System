module UART_RX_data_sampling (
  input wire         CLK ,
  input wire         RST ,
  input wire [5 : 0] Prescale ,
  input wire         RX_IN ,
  input wire         dat_samp_en ,
  input wire [5 : 0] edge_cnt ,
  output reg         sampled_bit
  );

reg  [2:0] samples ;
wire [5:0] threshold ; 

always @ (posedge CLK or negedge RST)
begin
  if(!RST)
    begin
      samples <= 0 ;
      sampled_bit <= 1  ;
      
    end
  else
    begin
    if(dat_samp_en == 1)
      begin
        if(edge_cnt == (threshold - 1 ))
          samples[0] <= RX_IN ;
        else if (edge_cnt == threshold)
          samples[1] <= RX_IN ;
        else if (edge_cnt == (threshold + 1 ))
          begin
           	samples[2] <= RX_IN ;
            if((samples == 'b111) || (samples == 'b011) || (samples == 'b101) || (samples == 'b110))
              sampled_bit <= 1 ;
            else if ((samples == 'b100) || (samples == 'b010) || (samples == 'b001) || (samples == 'b000) )
              sampled_bit <= 0 ;
            else
              sampled_bit <= 1 ;
          end
      end
  
end
end


assign threshold = Prescale / 2 ;

endmodule
