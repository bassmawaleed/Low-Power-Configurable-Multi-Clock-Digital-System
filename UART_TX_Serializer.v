module UART_TX_Serializer #(parameter data_width = 8) (
  input wire       				  CLK ,
  input wire       				  RST ,
  input wire [data_width - 1 : 0] P_DATA ,
  input wire       				  par_bit ,
  input wire 		[1:0] 		  mux_sel ,
  input wire       				  ser_en ,
  output reg       			      ser_done ,
  output reg       				  TX_OUT
  );
   
reg [3:0] counter ;
reg [data_width - 1 : 0] data ;
reg       data_out ;
reg       ser_done_comb ;
always @ (*)
begin
  if(ser_en == 1 )
  begin
    
    if(mux_sel == 'b10)
      begin
      case (counter)
        'b000 : begin
                  data_out = data[0] ;
                  ser_done = 1'b0 ;
                end
        'b001 : begin
                  data_out = data[1] ;
                  ser_done = 1'b0 ;
                end
        'b010 : begin
                  data_out = data[2] ;
                  ser_done = 1'b0 ;
                end
        'b011 : begin
                  data_out = data[3] ;
                  ser_done = 1'b0 ;
                end
        'b100 : begin
                  data_out = data[4] ;
                  ser_done = 1'b0 ;
                end
        'b101 : begin
                  data_out = data[5] ;
                  ser_done = 1'b0 ;
                end
        'b110 : begin
                  data_out = data[6] ;
                  ser_done = 1'b0 ;
                end
        'b111 : begin
                  data_out = data[7] ;
                  ser_done = 1'b1 ;
                end
          default : begin
                  data_out = 1 ;
                  ser_done = 1'b0;
                end
      endcase
      end
      else
        begin
          data_out = 1 ;
          ser_done = 1'b0;
        end
    
 
      end 
   else
     begin
      ser_done = 1'b0 ;  
      data_out = 1 ;
     end
end

always @ (posedge CLK )
begin
  if(ser_en == 1 && counter == 0 && mux_sel == 'b00)
  begin
    data <= P_DATA ;
  end  
end


always @ (posedge CLK or negedge RST)
begin
  if (!RST) 
    begin    
      counter <= 0 ;  /*reset the counter of serializer */   
    end
  else
    begin
    if(counter != 8 && mux_sel == 'b10)
      counter <= counter + 1 ;
    else
      counter <= 0 ;
    end
end

always @  (*)
begin
  case(mux_sel)
    
  2'b00: begin 
            TX_OUT = 0 ; /* Start Bit */
          end
  2'b01: begin 
            TX_OUT = 1 ; /* Stop Bit */
          end
  2'b10: begin 
            TX_OUT = data_out ; 
          end
  2'b11: begin 
            TX_OUT = par_bit ; 
          end
  endcase
end

endmodule

