`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:14:35 04/05/2018
// Design Name:   transciever
// Module Name:   C:/.Xilinx/module/testbench.v
// Project Name:  module
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: transciever
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench;

	// Inputs
	reg rst;
	reg data_in;
	reg clk;
	reg uart_rx;
	reg tx_wr;

	// Outputs
	wire q;
	wire [7:0] data_out;
	wire uart_tx;
	
	
	task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     i;
    begin
      
      // Send Start Bit
		
	  uart_rx <= 1'b0;
      #8635;
      //#1000;*/
      
      //Send Data Byte
     for (i=0; i<8; i=i+1)
        begin
          uart_rx <= i_Data[i];
          #8635;
        end
		  uart_rx <=1'b1;
		  #8635;
		//data_in<=i_Data[7]	 
		end
  endtask // UART_WRITE_BYTE*/
	

	// Instantiate the Unit Under Test (UUT)
	transciever uut (
		.q(q),
		.tx_wr(tx_wr),
		.uart_tx(uart_tx),
		.uart_rx(uart_rx),
		.data_out(data_out), 
		.rst(rst), 
		.data_in(q), 
		.clk(clk)
	);


	initial begin
	clk = 0;
	end
	always #5 clk=~clk;
	initial begin
		#1000;
		tx_wr=0;
		//#100000;
		//divisor=326;
		rst=1;
		#100;
		rst=0;
		UART_WRITE_BYTE(8'b10110010);
		#170000;
		tx_wr=1;
		#20;
		tx_wr=0;
		#170000;
		rst=1;
		#100;
		rst=0;
		UART_WRITE_BYTE(8'b10101010);
		#170000;
		tx_wr=1;
		#20;
		tx_wr=0;
		#170000;
		$finish();
	end
      

      
endmodule

