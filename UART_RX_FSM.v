module UART_RX_FSM (
  input wire       CLK,
  input wire       RST ,
  input wire       RX_IN ,
  input wire       PAR_EN ,
  input wire [5:0] edge_cnt ,
  input wire [4:0] bit_cnt ,
  input wire       par_err ,
  input wire       strt_glitch ,
  input wire       stp_err ,
  input wire [5:0] Prescale ,
  output reg       dat_samp_en ,
  output reg       enable ,
  output reg       deser_en ,
  output reg       data_valid ,
  output reg       stp_chk_en ,
  output reg       strt_chk_en ,
  output reg       par_chk_en 
  );


/* States definition */
parameter IDLE = 'b000 ; //IDLE State . No frame is sent 
parameter PRESTART = 'b001 ; //PRESTART State . To enable the edge counter and sampler .
parameter START = 'b011 ; //START State . To sample the start bit .
parameter DATA = 'b010 ;
parameter PARITY = 'b110 ;
parameter STOP = 'b111 ;

reg [2:0] current_state ;
reg [2:0] next_state ;

/* Counter for Errors */
reg	[1:0] counter_errors ;

reg [5:0] Prescale_reg ; /* For System */

always @ (posedge CLK or negedge RST)
begin
  if(!RST)
    begin
      Prescale_reg <= 0 ;
    end
  else
    begin
      Prescale_reg <= Prescale ;
    end
end

/* Present State Logic */
always @ (posedge CLK or negedge RST)
begin
  if(!RST)
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
    IDLE : begin
            if(RX_IN == 0)
              next_state = PRESTART ;
            else
              next_state = IDLE ;
          end
    PRESTART : begin
                  if(edge_cnt == ((Prescale_reg/2) + 1)) //Wait till the data sampler samples the start bit then move to the next state to enable the start checker
                    next_state = START ;
                  else
                    next_state = PRESTART ;
                  end
    START : begin
              if(strt_glitch == 1 && bit_cnt == 1)
                next_state = IDLE ;
              else if (strt_glitch == 0 && bit_cnt == 1)
                next_state = DATA ;
              else
                next_state = START ;
            end
    DATA :  begin
              if(PAR_EN == 1 && bit_cnt == 9)
                next_state = PARITY ;
              else if (PAR_EN == 0 && bit_cnt == 9)
                next_state = STOP ;
              else
                next_state = DATA ;
            end
    PARITY :  begin
              if (bit_cnt == 10)
                next_state = STOP ;
              else
                next_state = PARITY ;
            end
    STOP :  begin
			  if (RX_IN == 0 && edge_cnt == (Prescale_reg ))
                next_state = PRESTART ;
              else if(edge_cnt == (Prescale_reg ) || (counter_errors == 1 && stp_err == 1 && edge_cnt == (Prescale_reg/2 +  2)) )
                next_state = IDLE ;
              else 
                next_state = STOP ;
            end
    default : begin
                next_state = IDLE ;
              end
  endcase
end

/* Outputs Logic */
always @ (*)
begin
  case(current_state) 
    IDLE : begin
           dat_samp_en = 'b0 ;
           if(RX_IN ==0)
             enable = 'b1 ;
           else
             enable = 'b0 ;
           deser_en = 'b0 ;
           data_valid = 'b0;
           stp_chk_en = 'b0 ;
           strt_chk_en = 'b0 ;
           par_chk_en = 'b0 ;
          end
    
    PRESTART : begin
                  dat_samp_en = 'b1 ;
                  enable = 'b1 ;
                  deser_en = 'b0 ;
                  data_valid = 'b0;
                  stp_chk_en = 'b0 ;
                  strt_chk_en = 'b0 ;
                  par_chk_en = 'b0 ;
                  end
    START : begin
              dat_samp_en = 'b1 ;
              enable = 'b1 ;
              deser_en = 'b0 ;
              data_valid = 'b0;
              stp_chk_en = 'b0 ;
              strt_chk_en = 'b1 ;
              par_chk_en = 'b0 ;
          end
    DATA : begin
              dat_samp_en = 'b1 ;
              enable = 'b1 ;
              if( bit_cnt == 9 )
                deser_en = 'b0 ;
              else
                deser_en = 'b1 ;
              data_valid = 'b0;
              stp_chk_en = 'b0 ;
              strt_chk_en = 'b0 ;
              par_chk_en = 'b0 ;
          end
    PARITY : begin
              dat_samp_en = 'b1 ;
              enable = 'b1 ;
              deser_en = 'b0 ;
              data_valid = 'b0 ;
              stp_chk_en = 'b0 ;
              strt_chk_en = 'b0 ;
              par_chk_en = 'b1 ;
			  /*
			  if (edge_cnt == ((Prescale_reg/2) + 1) && par_err == 1 )
                parity_flag = 1'b1 ;
              else
                parity_flag = 1'b0 ;
				*/
          end
    STOP : begin
              dat_samp_en = 'b1 ;
              //enable = 'b1 ;
              deser_en = 'b0 ;
              stp_chk_en = 'b1 ;
              strt_chk_en = 'b0 ;
              par_chk_en = 'b0 ;
              if(counter_errors == 0 && edge_cnt == (Prescale_reg))
                begin
                data_valid = 'b1 ;
                enable = 'b0 ; //Disable the edge bit counter 
                end
              else
                begin
                data_valid = 'b0 ;
                enable = 'b1 ;
                end
                
          end
	default : begin
				dat_samp_en = 'b0 ;
				enable = 'b0 ;
			    deser_en = 'b0 ;
			    data_valid = 'b0;
			    stp_chk_en = 'b0 ;
			    strt_chk_en = 'b0 ;
			    par_chk_en = 'b0 ;
			end
    
  endcase
end


/* Errors counter logic */
always @ (posedge CLK or negedge RST)
begin
	if (!RST)
	begin
		counter_errors <= 0 ;
	end
	else
	begin
		if(par_err == 1 && edge_cnt == (Prescale_reg/2 + 2 ))
			counter_errors <= counter_errors + 1 ;
		if(stp_err == 1 && ( (bit_cnt == 9 && PAR_EN == 0) || (bit_cnt == 10 && PAR_EN == 1)) && edge_cnt == (Prescale_reg/2 + 2 ) )
			counter_errors <= counter_errors + 1 ;
		if(bit_cnt == 0)
			counter_errors <= 0 ;
	
	end

end






endmodule
