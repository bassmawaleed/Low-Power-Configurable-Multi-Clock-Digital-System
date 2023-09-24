module UART_TX_FSM (
  input wire CLK ,
  input wire RST ,
  input wire Data_Valid ,
  input wire PAR_EN ,
  input wire ser_done ,
  output reg ser_en ,
  output reg busy ,
  output reg [1:0] mux_select ,
  output reg       parity_read
  );
  

reg [2:0] current_state ;
reg [2:0] next_state ;
reg [3:0] counter ;

localparam [2:0] IDLE = 3'b000 ;
localparam [2:0] S_Start = 3'b001 ;
localparam [2:0] S_Data = 3'b011 ;
localparam [2:0] S_Stop = 3'b010 ;
localparam [2:0] S_Parity = 3'b110 ;

/* Present State Flip flop */
always @ (posedge CLK or negedge RST)
begin
  if( !RST )
    begin
      current_state <= IDLE ;
    end
  else
    begin
      current_state <= next_state ;
    end
end

/* Next State Logic */
always @ (*)
begin
  case(current_state)
    
    IDLE: begin
              if( Data_Valid == 1)
                next_state = S_Start ;
              else
                next_state = IDLE ;
          end
    S_Start : begin
                  next_state = S_Data ;
              end
    S_Data : begin
              if (ser_done == 1'b1 && PAR_EN == 1)
                next_state = S_Parity ;
              else if (ser_done == 1'b1 && PAR_EN == 0)
                next_state = S_Stop ;
              else
                next_state = S_Data ;
            end
    S_Parity : begin
                next_state = S_Stop ;
              end
    S_Stop : begin
                next_state = IDLE ;
             end
    default : next_state = IDLE ;
  endcase
end

/* Output Logic */
always @ (*)
begin
  case(current_state)
    IDLE : begin
              busy = 1'b0;
              mux_select = 2'b01 ;
              ser_en = 1'b0;
              parity_read  = 1'b0 ;
            end
    S_Start : begin
                busy = 1'b1;
                mux_select = 2'b00 ;
                ser_en = 1'b1;
                parity_read  = 1'b1 ;
              end
    S_Data : begin
                busy = 1'b1;
                mux_select = 2'b10 ;
                ser_en = 1'b1;
                parity_read  = 1'b0 ;
                  
            end
    S_Parity : begin
                busy = 1'b1;
                mux_select = 2'b11 ;
                ser_en = 1'b0 ;
                parity_read  = 1'b0 ;
              end
    S_Stop : begin
                busy = 1'b1 ;
                mux_select = 2'b01 ;
                ser_en = 1'b1 ;
                parity_read  = 1'b0 ;
             end
    default : begin
              busy = 1'b0;
              mux_select = 2'b01 ;
              ser_en = 1'b0;
              parity_read  = 1'b0 ;
              end
   endcase
end

/* Counter Logic */
always @ (posedge CLK or negedge RST)
begin
  if ( !RST )
    counter <= 0 ;
  else if (current_state == S_Data )
    counter <= counter + 1 ; 
  else
    counter <= 0 ;
end

endmodule

