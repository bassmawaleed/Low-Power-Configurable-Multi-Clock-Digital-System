module UART_RX_TOP(
  input wire         RX_IN ,       /* Serial Data IN */
  input wire [5 : 0] Prescale ,    /* Oversampling Prescale */
  input wire         PAR_EN ,      /* Parity_Enable         */
  input wire         PAR_TYPE ,    /* Parity Type           */
  input wire         CLK ,         /* UART RX Clock Signal */
  input wire         RST ,         /* Synchronized reset signal */
  output wire [7 : 0] P_DATA  ,     /* Frame Data Byte */
  output wire         data_valid ,   /* Data Byte Valid signal */
  output wire 		  par_err ,		/* Frame parity error */
  output wire 		  stp_err 		/* Frame stop error */
  );


/* Defining internal signals */
wire       internal_deser_en ;
wire       internal_sampled_bit ;
wire       internal_par_chk_en ;
wire       internal_edge_bit_enable ;
wire [4:0] internal_bit_cnt ;
wire [5:0] internal_edge_cnt ;
wire       internal_strt_chk_en ;
wire       internal_strt_glitch ;
wire       internal_stp_chk_en;
wire       internal_dat_samp_en ;

/* Taking an instance from the deserializer */
UART_RX_deserializer U0_deserializer (
.CLK(CLK),
.RST(RST),
.deser_en(internal_deser_en),
.sampled_bit(internal_sampled_bit),
.bit_cnt(internal_bit_cnt),
.P_DATA(P_DATA)
//.Prescale(Prescale),
//.edge_cnt(internal_edge_cnt)
);
  
/* Taking an instance from the parity checker */
UART_RX_parity_check U1_parity_check (
.PAR_TYPE(PAR_TYPE),
.par_chk_en(internal_par_chk_en),
.sampled_bit(internal_sampled_bit),
.par_err(par_err),
.P_DATA(P_DATA)
);

/* Taking an instance from the edge bit counter */
UART_RX_edge_bit_counter U2_edge_bit_counter (
.CLK(CLK),
.RST(RST),
.enable(internal_edge_bit_enable),
.bit_cnt(internal_bit_cnt),
.edge_cnt(internal_edge_cnt),
.Prescale(Prescale)
);

/* Taking an instance from the start check block */
UART_RX_strt_check U3_strt_check (
.sampled_bit(internal_sampled_bit),
.strt_chk_en(internal_strt_chk_en),
.strt_glitch(internal_strt_glitch)
);

/* Taking an instance from the stop check block */
UART_RX_stop_check U4_stop_check (
.sampled_bit(internal_sampled_bit),
.stp_chk_en(internal_stp_chk_en),
.stp_err(stp_err)
);

/* Taking an instance from FSM */
UART_RX_FSM U5_FSM (
.CLK(CLK),
.RST(RST),
.RX_IN(RX_IN),
.PAR_EN(PAR_EN),
.Prescale(Prescale),
.edge_cnt(internal_edge_cnt),
.bit_cnt(internal_bit_cnt),
.par_err(par_err),
.strt_glitch(internal_strt_glitch),
.stp_err(stp_err),
.dat_samp_en(internal_dat_samp_en),
.enable(internal_edge_bit_enable),
.deser_en(internal_deser_en),
.data_valid(data_valid),
.stp_chk_en(internal_stp_chk_en),
.strt_chk_en(internal_strt_chk_en),
.par_chk_en(internal_par_chk_en)
);

/* Taking an instance from the data sampler */
UART_RX_data_sampling U6_data_sampling (
.CLK(CLK),
.RST(RST),
.Prescale(Prescale),
.RX_IN(RX_IN),
.dat_samp_en(internal_dat_samp_en),
.edge_cnt(internal_edge_cnt),
.sampled_bit(internal_sampled_bit)
);

endmodule


