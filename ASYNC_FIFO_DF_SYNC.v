/* Double Flop Synchronizer with Multiple bit signal as an input */

module ASYNC_FIFO_DF_SYNC #(parameter INPUT_LENGTH = 4)(
  input wire [INPUT_LENGTH - 1 : 0] IN_DATA ,
  input wire                        CLK ,
  input wire                        RST ,
  output reg [INPUT_LENGTH - 1 : 0] OUT_DATA 
  );
  
integer i ;

reg [1:0] RegFile [INPUT_LENGTH - 1 : 0] ;

always @ (posedge CLK or negedge RST)
begin
  if(!RST)
    begin
      for (i = 0 ; i < INPUT_LENGTH ; i = i + 1)
      begin
        RegFile[i] <= 0 ;
      end
    end
  else
    begin
      for (i = 0 ; i < INPUT_LENGTH ; i = i + 1)
      begin
        RegFile[i] <= {RegFile[i][0],IN_DATA[i]};
      end
    end
end

always @ (*)
begin
  for ( i = 0 ; i < INPUT_LENGTH ; i = i + 1)
  begin
    OUT_DATA[i] = RegFile[i][1] ;
  end
end


endmodule

