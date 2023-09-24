`timescale 1ns/100ps 

module SYS_tb();

/* Defining Test bench parameters */
parameter DATA_WIDTH = 8 ;
parameter REF_CLK_PERIOD = 10.0 ;
parameter UART_CLK_PERIOD = 271.267 ;
parameter ADDRESS_WIDTH = 8 ;
parameter prescaler = 32 ;

integer i ; 
reg [DATA_WIDTH - 1 :0] Data ;
reg [ADDRESS_WIDTH - 1 :0] Address ;

/* Defining Testbench signals */
reg 						REF_CLK_tb ;
reg 						RST_tb ;
reg 						UART_CLK_tb ;
reg 					    RX_IN_tb ;
wire 					    TX_OUT_tb ;
wire 						PAR_ERR_tb ;
wire						STP_ERR_tb ;


/* DUT Instantiation */
TOP DUT (
.REF_CLK(REF_CLK_tb),
.RST(RST_tb),
.UART_CLK(UART_CLK_tb),
.RX_IN(RX_IN_tb),
.TX_OUT(TX_OUT_tb),
.PAR_ERR(PAR_ERR_tb),
.STP_ERR(STP_ERR_tb)
);


/* Clock Waveform Generator */
always 
#(REF_CLK_PERIOD / 2.0 ) REF_CLK_tb = ~REF_CLK_tb ;

always
#(UART_CLK_PERIOD / 2.0 ) UART_CLK_tb = ~UART_CLK_tb ;

/* Initial Block */
initial
begin
	$dumpfile("SYSTEM.vcd");
	$dumpvars ;
	
	/* Clock Enable */
	REF_CLK_tb = 1'b0 ;
	UART_CLK_tb = 1'b0 ;
	RX_IN_tb = 1'b1 ;
	
	/* Reset the system */
	RST_tb = 1'b1 ;
	#(REF_CLK_PERIOD) ;
	RST_tb = 1'b0 ;
	#(REF_CLK_PERIOD) ;
	RST_tb = 1'b1 ;
	
	first_command();
	//second_command();
	//third_command();
	//fourth_command();
		
	/*****************************************************************/
	#(100*UART_CLK_PERIOD) ;
	$stop ;
end

task first_command ;
	begin
		/**********************FIRST COMMAND**********************/
		/*First Frame */
		Data = 'hAA ;
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 0 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ; 
		
		/*Second Frame */
		Address = 'h04 ;
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Address[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ;
		
		/* Third Frame */
		Data = 'hA1 ;
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ;
	end
endtask

task second_command ;
	begin
		/**********************SECOND COMMAND**********************/
		/*First Frame */
		Data = 'hBB ;
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
			
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 0 ; 
		  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ; 
		
		
		/*Second Frame */
		Address = 'h03 ;
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Address[i] ;
		end
			
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 0 ; 
		  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ;
		
		
		#(120*prescaler*UART_CLK_PERIOD) ;
	
	end
endtask

task third_command ;
	begin
		/**********************THIRD COMMAND**********************/
		/*First Frame */
		Data = 'hCC ;
		
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 0 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ; 
		
		/* Second Frame */
		/* ALU Op A */
		
		Data = 'b1010 ;
		
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 0 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ;
		
		/* Third Frame */
		/* ALU Op B */
		Data = 'b1111 ;
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 0 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ;
		
		/* Fourth Frame */
		/* ALU Fun */
		Data = 'b0100 ; /* ANDING */
		
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ;
		
		
		#(120*prescaler*UART_CLK_PERIOD) ;
	end
endtask

task fourth_command ;
	begin
		/**********************FOURTH COMMAND**********************/
		/*First Frame */
		Data = 'hDD ;
		
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 0 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ; 
		
		/* Second Frame */
		/* ALU FUN */

		Data = 'b0010 ; /* Multiplication */
		
		#(prescaler*UART_CLK_PERIOD) ;
		RX_IN_tb = 1'b0 ; /* Start Bit */
		
		/* Sending data */
		for( i = 0 ; i < 8 ; i = i + 1 )
		begin
			#(prescaler*UART_CLK_PERIOD)
			RX_IN_tb = Data[i] ;
		end
		
		/* Parity Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ; 
	  
		/* Stop Bit */
		#(prescaler*UART_CLK_PERIOD)
		RX_IN_tb = 1 ;
		
		
		#(120*prescaler*UART_CLK_PERIOD) ;
	end
endtask
endmodule
