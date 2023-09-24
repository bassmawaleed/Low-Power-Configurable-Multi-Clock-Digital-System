/* Module Objectives */
/* The module is suppposed to count :
a) positive edges of the UART_RX CLK
b) The bit number in the frame 
Bit number = 0 --> Start Bit 
Bit number = 1 --> LSB of data sent
Bit number = 8 --> MSB of data sent 
Bit number = 9 --> Parity (If enabled)
Bit number = 10 --> Stop Bit 
*/

module UART_RX_edge_bit_counter (
  input wire CLK,
  input wire RST ,
  input wire enable ,
  input wire [5:0] Prescale ,
  output reg [4:0] bit_cnt ,
  output reg [5:0] edge_cnt 
  );



always @ (posedge CLK or negedge RST )
begin
  if(!RST)
    begin
      bit_cnt <= 0;
      edge_cnt <= 0;
    end
  else
    begin
      if (enable)
        begin
          if (edge_cnt == Prescale )
            begin
              bit_cnt <= bit_cnt + 1 ;
              edge_cnt <= 1; 
            end
          else
            edge_cnt <= edge_cnt + 1 ;
        end
      else begin
        bit_cnt <= 0;
        edge_cnt <= 1;
      end
    end
end

endmodule
