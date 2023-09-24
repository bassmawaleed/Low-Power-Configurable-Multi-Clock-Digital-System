module UART_TOP #(parameter DATA_WIDTH = 8)(
  input wire [DATA_WIDTH - 1 : 0] TX_P_DATA,
  input wire       				  TX_DATA_VALID ,  
  input wire       				  TX_PAR_EN ,
  input wire       				  TX_PAR_TYP ,
  input wire       				  TX_CLK ,
  input wire       				  TX_RST ,
  output wire      				  TX_OUT ,
  output wire      				  TX_Busy ,

  input wire         RX_IN ,       /* Serial Data IN */
  input wire [5 : 0] RX_Prescale ,    /* Oversampling Prescale */
  input wire         RX_PAR_EN ,      /* Parity_Enable         */
  input wire         RX_PAR_TYPE ,    /* Parity Type           */
  input wire         RX_CLK ,         /* UART RX Clock Signal */
  input wire         RX_RST ,         /* Synchronized reset signal */
  output wire [7 :0] RX_P_DATA  ,     /* Frame Data Byte */
  output wire        RX_data_valid  ,  /* Data Byte Valid signal */
  output wire 		 par_err ,		/* Frame parity error */
  output wire 		 stp_err 		/* Frame stop error */
);


UART_TX_TOP #(.data_width(DATA_WIDTH)) U0_UART_TX_TOP (
.P_DATA(TX_P_DATA),
.DATA_VALID(TX_DATA_VALID),
.PAR_EN(TX_PAR_EN),
.PAR_TYP(TX_PAR_TYP),
.CLK(TX_CLK),
.RST(TX_RST),
.TX_OUT(TX_OUT),
.Busy(TX_Busy)
);

UART_RX_TOP U1_UART_RX_TOP (
.RX_IN(RX_IN),
.Prescale(RX_Prescale),
.PAR_EN(RX_PAR_EN),
.PAR_TYPE(RX_PAR_TYPE),
.CLK(RX_CLK),
.RST(RX_RST),
.P_DATA(RX_P_DATA),
.data_valid(RX_data_valid),
.par_err(par_err),
.stp_err(stp_err)
);

endmodule 
