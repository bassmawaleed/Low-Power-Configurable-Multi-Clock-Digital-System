module TOP 
#(
parameter DATA_WIDTH = 8 , 
parameter Add_Bus_Width = 4 ,
parameter Write_Bus_Width = 8 ,
parameter Read_Bus_Width = 8 ,
parameter ALU_FUN_WIDTH = 4 ,
parameter ALU_OUT_WIDTH = 16 
)
(
input wire 						   REF_CLK ,
input wire 						   RST ,
input wire 						   UART_CLK ,
input wire 						   RX_IN ,
output wire						   TX_OUT ,
output wire 					   PAR_ERR ,
output wire						   STP_ERR
);

/* Defining internal_signals */
wire 	[DATA_WIDTH - 1 : 0] 	 internal_received_data ;			/* From UART_TOP to DATA_SYNC */
wire 					  		 internal_received_data_valid ;		/* From UART_TOP to DATA_SYNC */
wire 	[DATA_WIDTH - 1 : 0] 	 internal_sync_received_data ; 		/* From DATA_SYNC to SYS_CTRL */
wire 					  		 internal_sync_received_data_valid; /* From UART_TOP to DATA_SYNC */
wire					  		 internal_sync_rst_2 ;				/* From RST_SYNC_2 to UART_TOP */
wire					  		 internal_sync_rst_1 ;				/* From RST_SYNC_1 to DATA_SYNC,REGFile */

wire   [Add_Bus_Width - 1 : 0]	 internal_address_bus ; 			/*From SYS_CTRL to RegFile */
wire					  		 internal_Write_Enable ; 			/*From SYS_CTRL to RegFile */
wire					  		 internal_Read_Enable ; 			/*From SYS_CTRL to RegFile */
wire   [Write_Bus_Width- 1 : 0]  internal_Write_Data ; 				/*From SYS_CTRL to RegFile */
wire   [Read_Bus_Width - 1 : 0]  internal_Read_Data ; 				/*From RegFile to SYS_CTRL */
wire					  		 internal_Read_Data_Valid ; 		/*From RegFile to SYS_CTRL */

wire							 internal_FIFO_FULL_FLAG ;			/*From FIFO to SYS_CNTRL */
wire							 internal_FIFO_EMPTY_FLAG ;			/*From FIFO to UART_TX */
wire 	[DATA_WIDTH - 1 : 0] 	 internal_FIFO_Wr_data   ;			/* From SYS_CNTRL to FIFO */
wire							 internal_FIFO_WR_INCR ;			/* From SYS_CNTRL to FIFO */
wire							 internal_FIFO_RD_INCR ;			/* From PULSE_GEN to FIFO */
wire 	[DATA_WIDTH - 1 : 0]	 internal_FIFO_RD_DATA ;			/* From FIFO to UART_TX */

wire 	[DATA_WIDTH - 1 : 0]     internal_REG0 ;					/* From RegFile to ALU */
wire 	[DATA_WIDTH - 1 : 0]     internal_REG1 ;					/* From RegFile to ALU */
wire 	[DATA_WIDTH - 1 : 0] 	 internal_REG2 ;					/* From RegFile to UART_TOP */
wire 	[DATA_WIDTH - 1 : 0]     internal_REG3 ;					/* From RegFile to Clock_Divider*/

wire							 internal_TX_CLK ;					/* From Clock_Divider to Clock Domain 2*/
wire							 internal_TX_Busy ;					/* From UART_TX to PULSE_GEN*/

wire							 internal_RX_CLK ;					/* From Clk Div to UART_RX */
wire 			[7:0]			 internal_MUX_Div_ratio ;			/* From Custom Mux to Clock Divider */

wire 	[ALU_FUN_WIDTH - 1 : 0]	 internal_ALU_FUN ;					/* From SYS_CNTRL to ALU */
wire 							 internal_ALU_EN ;					/* From SYS_CNTRL to ALU */
wire 	[ALU_OUT_WIDTH - 1 : 0]  internal_ALU_OUT ;					/* From ALU to SYS_CNTRL */
wire							 internal_ALU_CLK ;					/* From CLK_GATE to ALU */
wire						     internal_ALU_out_valid ;			/* From ALU to SYS_CNTRL */

wire							 internal_CLK_GATE_ENABLE ; 		/* From SYS_CNTRL to CLK_GATE */

wire							 internal_CLK_DIV_ENABLE ; 			/* From SYS_CNTRL to CLK_DIV's  */

/* Taking an instance from ALU */
ALU #(.output_width(ALU_OUT_WIDTH)) U0_ALU (
.A(internal_REG0),									/* From RegFile */
.B(internal_REG1),									/* From RegFile */
.ALU_FUN(internal_ALU_FUN), 						/* From SYS_CNTRL */
.CLK(internal_ALU_CLK),								/* From CLK_GATE */
.RST(internal_sync_rst_1),							/* From RST_SYNC_1 */
.Enable(internal_ALU_EN),							/* From SYS_CNTRL*/
.ALU_OUT(internal_ALU_OUT),							/* To SYS_CNTRL */
.Out_Valid(internal_ALU_out_valid)					/* To SYS_CNTRL */
);

/* Taking an instance from RegFile */
RegFile #(.Address_Bus_Width(Add_Bus_Width) , .Write_Bus_Width(Write_Bus_Width) , .Read_Bus_Width(Read_Bus_Width)) U1_RegFile (
.WrData(internal_Write_Data),				   		/* From SYS_CNTRL */
.Address(internal_address_bus),				   		/* From SYS_CNTRL */
.WrEn(internal_Write_Enable),				   		/* From SYS_CNTRL */
.RdEn(internal_Read_Enable),				   		/* From SYS_CNTRL */
.CLK(REF_CLK),								   		/* From Sytem Input Port */
.RST(internal_sync_rst_1),					   		/* From RST_SYNC_1 */
.RdData(internal_Read_Data),				   		/* To SYS_CNTRL */
.RdData_Valid(internal_Read_Data_Valid),	   		/* To SYS_CNTRL */
.REG0(internal_REG0),						   		/* To ALU */
.REG1(internal_REG1),						   		/* To ALU */
.REG2(internal_REG2),						   		/* Bit 0 (Parity Enable)To UART.TX_PAR_EN & UART.RX_PAR_EN , Bit 1 (Parity Type)To UART.TX_PAR_TYP & UART.RX_PAR_TYP */
.REG3(internal_REG3)						   		/* To Clock_Divider */
);

/* Taking an instance from ClkDiv for TX */
ClkDiv U4_ClkDiv (
.i_ref_clk(UART_CLK),								/* From TOP input port */
.i_rst_n(internal_sync_rst_2),						/* From RST_SYNC_2 */
.i_clk_en(internal_CLK_DIV_ENABLE),					/* From SYS_CNTRL */
.i_div_ratio(internal_REG3),						/* From RegFile */
.o_div_clk(internal_TX_CLK)							/* To UART_TOP(TX Clk) */
);

/* Taking an instance from UART_TOP */
UART_TOP #(.DATA_WIDTH(DATA_WIDTH)) U5_UART_TOP (
.TX_P_DATA(internal_FIFO_RD_DATA),					/* From FIFO */
.TX_DATA_VALID(~internal_FIFO_EMPTY_FLAG),  		/* From FIFO */
.TX_PAR_EN(internal_REG2[0]) ,						/* From RegFile */
.TX_PAR_TYP(internal_REG2[1]) ,						/* From RegFile */
.TX_CLK(internal_TX_CLK) ,							/* From ClkDiv */
.TX_RST(internal_sync_rst_2) ,						/* From RST_SYNC_2 */
.TX_OUT(TX_OUT) ,									/* To System Output Port */
.TX_Busy(internal_TX_Busy) ,						/* To Pulse Generator */

.RX_IN(RX_IN) ,       								/* From System Input Port */
.RX_Prescale(internal_REG2[DATA_WIDTH-1:2]) ,    	/* From RegFile */
.RX_PAR_EN(internal_REG2[0]) ,      				/* From RegFile */
.RX_PAR_TYPE(internal_REG2[1]) ,   	 				/* From RegFile */
.RX_CLK(internal_RX_CLK) ,         						/* UART RX Clock Signal */
.RX_RST(internal_sync_rst_2) ,         				/* From RST_SYNC_2 */
.RX_P_DATA(internal_received_data)  ,     			/* To Data Sync */
.RX_data_valid(internal_received_data_valid)  ,  	/* To Data Sync */
.par_err(PAR_ERR),									/* To System Output port */
.stp_err(STP_ERR)									/* To System Output port */
);

/* Taking an instance from RST_SYNC for Clock Domain 2 */
RST_SYNC U8_RST_SYNC_2 (
.CLK(UART_CLK),										/* From TOP Input Port */
.RST(RST),											/* From TOP Input Port */
.SYNC_RST(internal_sync_rst_2)						/* To UART_TOP , CLK_DIV , PULSE_GEN , ASYNC_FIFO(Rd domain) and ClkDiv(RX) */
);

/* Taking an instance from Data_Sync */
Data_Sync U9_Data_Sync (
.dest_clk(REF_CLK),									/* From TOP Input Port */
.dest_rst(internal_sync_rst_1),						/* From RST_SYNC_1 */
.unsync_bus(internal_received_data),				/* From UART_RX */
.bus_enable(internal_received_data_valid),			/* From UART_RX */
.sync_bus(internal_sync_received_data),				/* To SYS_CTRL */
.enable_pulse_d(internal_sync_received_data_valid)	/* To SYS_CTRL*/
);

/* Taking an instance from SYS_CTRL */
SYS_CTRL #(.ALU_FUNC_WIDTH(ALU_FUN_WIDTH) ,.alu_output_width(ALU_OUT_WIDTH)) U3_SYS_CTRL (
.CLK(REF_CLK),										/* From TOP Input Port */
.RST(internal_sync_rst_1),							/* From RST_SYNC_1 */
.ALU_OUT(internal_ALU_OUT),							/* From ALU */
.OUT_VALID(internal_ALU_out_valid),					/* From ALU */
.RX_P_DATA(internal_sync_received_data),			/* From Data Sync */
.RX_D_VALID(internal_sync_received_data_valid),		/* From Data Sync */
.RD_DATA(internal_Read_Data),						/* From Reg File */
.RD_DATA_VALID(internal_Read_Data_Valid),			/* From Reg File */
.FIFO_FULL(internal_FIFO_FULL_FLAG),				/* From FIFO */
.ALU_EN(internal_ALU_EN),							/* To ALU */
.ALU_FUN(internal_ALU_FUN),							/* To ALU */
.CLK_EN(internal_CLK_GATE_ENABLE),					/* To CLK_GATE */
.Address(internal_address_bus),						/* To Reg File */
.WrEn(internal_Write_Enable),						/* To Reg File */
.RdEn(internal_Read_Enable),						/* To Reg File */
.WrData_Reg_File(internal_Write_Data),				/* To Reg File */
.WrData_FIFO(internal_FIFO_Wr_data),				/* To FIFO */
.WR_INC(internal_FIFO_WR_INCR),						/* To FIFO */
.clk_div_en(internal_CLK_DIV_ENABLE)				/* To Clock Dividers */
);

/* Taking an instance from PULSE_GEN (Pulse Gen for RD_INC )*/
PULSE_GEN U7_PULSE_GEN (
.CLK(internal_TX_CLK),								/* From Clock Divider */
.RST(internal_sync_rst_2),							/* From RST_SYNC_2 */
.LVL_SIG(internal_TX_Busy),							/* From UART_TX */
.PULSE_SIG(internal_FIFO_RD_INCR)					/* To FIFO */
);

/* Taking an instance from ASYNC_FIFO_TOP */

ASYNC_FIFO_TOP U10_ASYNC_FIFO_TOP (
.W_CLK(REF_CLK),									/* From TOP Input Port */
.W_RST(internal_sync_rst_1),						/* From RST_SYNC_1 */
.W_INC(internal_FIFO_WR_INCR),						/* From SYS_CNTRL */
.R_CLK(internal_TX_CLK),							/* From Clock Divider */
.R_RST(internal_sync_rst_2),						/* From RST_SYNC_2 */
.R_INC(internal_FIFO_RD_INCR),						/* From PULSE_GEN */
.WR_DATA(internal_FIFO_Wr_data),					/* From SYS_CNTRL */
.RD_DATA(internal_FIFO_RD_DATA),					/* To UART_TX */
.FULL(internal_FIFO_FULL_FLAG),						/* To SYS_CNTRL */
.EMPTY(internal_FIFO_EMPTY_FLAG)					/* To UART_TX */
);

/* Taking an instance from RST_SYNC for Clock Domain 1 */
RST_SYNC U_RST_SYNC_1 (
.CLK(REF_CLK),										/* From TOP Input Port */
.RST(RST),											/* From TOP Input Port */
.SYNC_RST(internal_sync_rst_1)						/* To ASYNC_FIFO_TOP(Wr domain) , SYS_CNTRL , DATA_SYNC , RegFile and ALU */
);

/* Taking an instance from CLK_GATE */
CLK_GATE U2_CLK_GATE (
.CLK(REF_CLK),										/* From TOP Input Port */
.CLK_EN(internal_CLK_GATE_ENABLE),  				/* From SYS_CNTRL */
.GATED_CLK(internal_ALU_CLK)						/* To ALU */
);

MUX_to_CLK_DIV U11_MUX_to_CLK_DIV (
.prescaler(internal_REG2[DATA_WIDTH-1:2]),			/* From RegFile*/
.i_div_ratio(internal_MUX_Div_ratio)				/* To ClkDiv */
);

/* Taking an instance from ClkDiv for RX */
ClkDiv U12_ClkDiv (
.i_ref_clk(UART_CLK),								/* From Top Input Port */
.i_rst_n(internal_sync_rst_2),						/* From RST_SYNC_2 */
.i_clk_en(internal_CLK_DIV_ENABLE),					/* From SYS_CNTRL */
.i_div_ratio(internal_MUX_Div_ratio),				/* From Custom Mux */
.o_div_clk(internal_RX_CLK)							/* To UART_RX_CLK */
);

endmodule 
