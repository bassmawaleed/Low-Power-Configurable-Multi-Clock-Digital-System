module ClkDiv #(parameter division_ratio = 8)
(
  input wire        				   i_ref_clk ,
  input wire        				   i_rst_n , 
  input wire        				   i_clk_en ,
  input wire 		[7 : 0]  		   i_div_ratio ,
  output wire        				   o_div_clk 
  );
  
  
reg [6:0] counter_value ;  
reg [7:0] counter_even ;  
reg [7:0] counter_odd ; 
reg		  div_clk ;
wire	  clk_en ;

always @ (posedge i_ref_clk or negedge i_rst_n)  
begin
  
  if(!i_rst_n)
    begin
      div_clk <= 1'b0;
      counter_even <= 'b0;
      counter_odd <= 'b0;
    end
  else
    begin
      if(i_clk_en && i_div_ratio != 0 && i_div_ratio != 1 )
      begin
        
        if( i_div_ratio[0] == 0) //Even ratio 
          begin
            
          if(counter_even == (counter_value - 1)) //We should toggle here 
            begin
              div_clk <= ~ div_clk ;
              counter_even <= 'b0; /* Restart the counter */
            end
          else
            counter_even <= counter_even + 1 ;
            
          end
        else //Odd ratio
        begin
          
          if( (!div_clk && (counter_odd == counter_value ) ) || (div_clk && (counter_odd == counter_value - 1) ))
            begin
              div_clk <= ~ div_clk ;
              counter_odd <= 'b0; /* Restart the counter */
            end
          else
            begin
              counter_odd <= counter_odd + 1 ;
            end
          
        end
       end
       
      end
  
  
  
end
  
always @ (*)
begin
	counter_value = ( i_div_ratio >> 1 ); //Divide the ratio by two .
end

assign clk_en = i_clk_en & !(i_div_ratio == 1'b1) & !(~|i_div_ratio) ;
assign o_div_clk = clk_en ? div_clk : i_ref_clk ; 

endmodule

