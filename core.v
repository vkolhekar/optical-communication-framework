// Code your design here
`timescale 1ns / 1ps

module transciever(
output reg q,
input uart_rx,
output uart_tx,
input tx_wr,
output reg [7:0] data_out,
input rst,
//input [7:0] a,
input data_in,
input clk);

//---------------------------tx part------------------------------------------------------------------------------//
parameter divisorb = 54;
reg  		[15:0] divisor = divisorb;
wire [7:0] a;
wire rst;
reg [8:0]temp;
//reg[27:0] counter=28'd0;
reg done=0;
//parameter DIVISOR = 28'd4;
parameter startbit=1'b1;
//parameter idle = 2'b00;
parameter idle_tx = 2'b00;
parameter load = 2'b01;
parameter piso = 2'b10;
reg [1:0] maine=0;
integer bitcount;
integer cpb_tx=4;
reg [15:0] count=0;
initial data_in_sample=4'b0000;
initial q=0;
//initial data_in<=0;
//----------------------------rx part---------------------------------------------------------//
parameter start_bit     =3'b000;
parameter centre        =3'b001;
parameter sampling      =3'b010;
parameter over          =3'b011;

reg ov=0;
reg [3:0] data_in_sample=0;
reg data_in1;
reg data_in2;
//output data_in_sample;
//cpb= clks per bit , bi=bit index
integer cpb=4;
reg [3:0] bi=0;
reg [10:0] cc=0;
reg [7:0] reg_out;
reg c;
reg done_rx;
reg [2:0] main =0;

//---------------------------------uart core called--------------------------------------------//
uart_transceiver instance_name (
    .sys_rst(rst), 
    .sys_clk(clk), 
    .uart_rx(uart_rx), 
    .uart_tx(uart_tx), 
    .divisor(divisor), 
    .rx_data(a), 
    .rx_done(rx_done), 
    .tx_data(data_out), 
    .tx_wr(tx_wr), 
    .tx_done(tx_done)
    );

//----------------------------------tx--------------------------------------------------//

always@(posedge clk)
begin
case (maine)
	idle_tx:
		begin
		if(rst)
			begin
			count<=0;
			bitcount<=0;
			temp <= 0;
			end
		else
			begin
			if(rx_done)
				maine<=load;
			else
				maine<=idle_tx;
		end
		end
		
	load:
	begin
	/*if(count<cpb_tx-1)
		begin
			count<=count+1;
			maine<=load;
		end
	else
		begin*/
			count<=0;
			temp[8] <= a[7];
			temp[7] <= a[6];
			temp[6] <= a[5];
			temp[5] <= a[4];
			temp[4] <= a[3];
			temp[3] <= a[2];
			temp[2] <= a[1];
			temp[1] <= a[0];
			temp[0] <= startbit;
			maine<=piso;
		//end
	end
	piso:
	begin
		
		q <= temp[bitcount];
		//temp <= {temp[7:0],1'b0};
		if(count<cpb_tx-1)
		begin
		count<=count+1;
		maine<=piso;
		end
		else
		begin
			count<=0;
          if(bitcount<9)
			begin
				bitcount<=bitcount+1;
				maine<=piso;
			end
			else
			begin
				q<=0;
				bitcount<=0;
				done<=1;
            //$finish();
				maine<=idle_tx;
			end
		end
	end
	endcase
end 

//---------------------------rx part------------------------------------------------------------------------------//



always@(posedge clk)
	begin
		data_in1<=data_in;
		data_in2<=data_in1;
	end
always@(posedge clk) begin

	case(main)
		start_bit:
			begin
			if(rst)
				begin
				cc<=0;
				bi<=0;
				end
			else
				begin
				data_in_sample[3:0]<={data_in_sample[2:0], data_in1};
				if(data_in_sample == 4'b0011)//start bit detected
					begin
					c<=1;
					main<=centre;
					end
				else
					begin
					main<=start_bit;
					end
			end	
			end	
		
		centre:
			begin 	
			cc<=0;
			bi<=0;
			main<=sampling;
			end
		
		sampling:
			begin
				if (cc < cpb-1)
					begin
						cc<=cc+1;
						main<=sampling;
					end
				else
					begin
						cc<=0;
						data_out[bi]<= data_in2;
						if(bi<8)
							begin
								bi<=bi+1;
								main<=sampling;
							end
						else
							begin
								data_in_sample<=4'b0000;
								bi<=0;
								//done_rx<=1'b1;
								ov<=1'b1;
								main<=over;
							end
					end
			end
		
		over:
		begin
			bi<=0;
			main<=start_bit;
		end
		
		default :
			main<=start_bit;
		
	endcase
	/*if(tx_done)
	begin
	$finish();
	end*/
end


			
endmodule			

