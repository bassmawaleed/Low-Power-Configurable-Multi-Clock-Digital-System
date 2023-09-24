module UART_TX_TOP #(parameter data_width = 8)(
  input wire [data_width - 1 : 0] P_DATA,
  input wire       				  DATA_VALID ,  
  input wire       				  PAR_EN ,
  input wire       				  PAR_TYP ,
  input wire       				  CLK ,
  input wire       				  RST ,
  output wire      				  TX_OUT ,
  output wire      				  Busy 
  );
  
  
wire       par_bit ;
wire       ser_done_out ;
wire       ser_en_out ;
wire [1:0] mux_select_out ;
wire       parity_read_U ;

/* Taking an instance from Parity Calculator */
UART_TX_Parity_Calc UART_TX_Parity_Calc (
.CLK(CLK),
.P_DATA(P_DATA),
.PAR_TYP(PAR_TYP),
.par_bit(par_bit),
.parity_read(parity_read_U)
);
  

/* Taking an instance from FSM */
UART_TX_FSM UART_TX_FSM (
.CLK(CLK),
.RST(RST),
.Data_Valid(DATA_VALID),
.PAR_EN(PAR_EN),
.ser_done(ser_done_out),
.ser_en(ser_en_out),
.busy(Busy),
.mux_select(mux_select_out),
.parity_read(parity_read_U)
);
  
/* Taking an instance from serializer */
UART_TX_Serializer UART_TX_Serializer (
.CLK(CLK),
.RST(RST),
.P_DATA(P_DATA),
.ser_en(ser_en_out),
.mux_sel(mux_select_out),
.TX_OUT(TX_OUT),
.ser_done(ser_done_out),
.par_bit(par_bit)
);


endmodule


