module ASYNC_FIFO_TOP #(parameter DATA_WIDTH = 8 , parameter PTR_WIDTH = 4 , parameter ADD_WIDTH = 3 , parameter FIFO_DEPTH = 8)(
  input wire                       W_CLK ,   /* Source domain clock */
  input wire                       W_RST ,   /* Source domain Async reset  */
  input wire                       W_INC ,   /* Write operation enable */
  input wire                       R_CLK ,   /* Destination domain clock */
  input wire                       R_RST ,   /* Destination domain Async reset */
  input wire                       R_INC ,   /* Read operation enable */
  input wire  [DATA_WIDTH - 1 : 0] WR_DATA , /* Write Data Bus */
  output wire [DATA_WIDTH - 1 : 0] RD_DATA , /* Read Data Bus */
  output wire                      FULL ,    /* FIFO Buffer full flag */ 
  output wire                      EMPTY     /* FIFO Buffer empty flag */
  );

/* Defining Internal Signals */
wire [ADD_WIDTH - 1 : 0] internal_w_addr ;
wire [ADD_WIDTH - 1 : 0] internal_r_addr ;

wire [PTR_WIDTH - 1 : 0] internal_w_ptr ;
wire [PTR_WIDTH - 1 : 0] internal_r_ptr ;

wire [PTR_WIDTH - 1 : 0] internal_wq2_rptr ;
wire [PTR_WIDTH - 1 : 0] internal_rq2_wptr ;

/* Taking an instance from FIFO_MEM_CNTRL */
ASYNC_FIFO_MEM_CNTRL #(.data_width(DATA_WIDTH) , .add_width(ADD_WIDTH) , .fifo_depth(FIFO_DEPTH)) U0_FIFO_MEM_CNTRL (
.w_inc(W_INC),
.w_full(FULL),
.w_clk(W_CLK),
.w_rst(W_RST),
.w_data(WR_DATA),
.w_addr(internal_w_addr),
.r_addr(internal_r_addr),
.r_data(RD_DATA)
);

/* Taking an instance from DF_SYNC (From Read Domain to Write Domain)*/
ASYNC_FIFO_DF_SYNC #(.INPUT_LENGTH(PTR_WIDTH)) U1_DF_SYNC (
.IN_DATA(internal_r_ptr),
.CLK(W_CLK),
.RST(W_RST),
.OUT_DATA(internal_wq2_rptr)
);

/* Taking an instance from DF_SYNC (From Write Domain to Read Domain)*/
ASYNC_FIFO_DF_SYNC #(.INPUT_LENGTH(PTR_WIDTH)) U2_DF_SYNC (
.IN_DATA(internal_w_ptr),
.CLK(R_CLK),
.RST(R_RST),
.OUT_DATA(internal_rq2_wptr)
);

/* Taking an instance from FIFO_WR */
ASYNC_FIFO_WR #(.ptr_width(PTR_WIDTH) , .add_width(ADD_WIDTH)) U3_FIFO_WR (
.w_inc(W_INC),
.w_clk(W_CLK),
.wrst_n(W_RST),
.wq2_rptr(internal_wq2_rptr),
.wfull(FULL),
.waddr(internal_w_addr),
.gray_wptr(internal_w_ptr)
);

/* Taking an instance from FIFO_RD */
ASYNC_FIFO_RD #(.ptr_width(PTR_WIDTH) , .add_width(ADD_WIDTH)) U4_FIFO_RD (
.r_inc(R_INC),
.r_clk(R_CLK),
.rrst_n(R_RST),
.rq2_wptr(internal_rq2_wptr),
.rempty(EMPTY),
.raddr(internal_r_addr),
.gray_rptr(internal_r_ptr)
);




endmodule

