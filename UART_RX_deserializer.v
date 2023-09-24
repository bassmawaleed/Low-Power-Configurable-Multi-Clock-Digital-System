module UART_RX_deserializer (
  input wire       CLK ,
  input wire       RST ,
  input wire       deser_en ,
  input wire       sampled_bit ,
  input wire [4:0] bit_cnt ,
  output reg [7:0] P_DATA
  );


always @ (posedge CLK or negedge RST)
begin
  if(!RST)
    P_DATA <= 0 ;
  else
    begin
      if ( deser_en == 1 )
      begin
        case (bit_cnt)  
        'b001 : begin
               P_DATA[0] <=  sampled_bit ;
            end
        'b010 : begin
               P_DATA[1] <=  sampled_bit ;
            end
        'b011 : begin
               P_DATA[2] <=  sampled_bit ;
            end
        'b100 : begin
               P_DATA[3] <=  sampled_bit ;
            end
        'b101 : begin
               P_DATA[4] <=  sampled_bit ;
            end
        'b110 : begin
               P_DATA[5] <=  sampled_bit ;
            end
        'b111 : begin
               P_DATA[6] <=  sampled_bit ;
            end
        'b1000 : begin
               P_DATA[7] <=  sampled_bit ;
            end
        default : begin
               P_DATA <=  0 ;
            end
    endcase
  end
end
end


/* counter_deserializer Logic */
/*
always @ (posedge CLK or negedge RST)
begin
  if (!RST)
  begin
    counter_deserializer <= 0 ;
  end
  else if ( deser_en == 1 )
    begin
      if(counter_deserializer == 7) 
        counter_deserializer <= 0 ;
      else
        counter_deserializer <= counter_deserializer + 1;
    end
end
*/

endmodule

/*
module deserializer (
  input wire       CLK ,
  input wire       RST ,
  input wire       deser_en ,
  input wire       sampled_bit ,
  input wire [4:0] Prescale ,
  input wire [4:0] bit_cnt ,
  input wire [4:0] edge_cnt ,
  output reg [7:0] P_DATA
  );


always @ (posedge CLK or negedge RST)
begin
  if(!RST)
    P_DATA <= 1 ;
  else
    begin
      if ( deser_en == 1 && edge_cnt == (Prescale/2 +  2) )
      begin
        case (bit_cnt)  
          'b001 : begin
               P_DATA[0] <=  sampled_bit ;
              end
          'b010 : begin
               P_DATA[1] <=  sampled_bit ;
              end
          'b011 : begin
               P_DATA[2] <=  sampled_bit ;
              end
          'b100 : begin
               P_DATA[3] <=  sampled_bit ;
              end
          'b101 : begin
               P_DATA[4] <=  sampled_bit ;
              end
          'b110 : begin
               P_DATA[5] <=  sampled_bit ;
              end
          'b111 : begin
               P_DATA[6] <=  sampled_bit ;
              end
          'b1000 : begin
               P_DATA[7] <=  sampled_bit ;
              end
          default : begin
               P_DATA =  0 ;
              end
      endcase
    end
  end
end

*/
/* counter_deserializer Logic */
/*
always @ (posedge CLK or negedge RST)
begin
  if (!RST)
  begin
    counter_deserializer <= 0 ;
  end
  else if ( deser_en == 1 )
    begin
      if(counter_deserializer == 7) 
        counter_deserializer <= 0 ;
      else
        counter_deserializer <= counter_deserializer + 1;
    end
end
*/

//endmodule

