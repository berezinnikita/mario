`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2025 08:01:59 PM
// Design Name: 
// Module Name: i2s_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module i2s_tx #(
	parameter AUDIO_DW	= 33
)(
    input           clk,
	input			rst,
		
    input [AUDIO_DW-1:0]	left_chan,
    input [AUDIO_DW-1:0]	right_chan,
    

	// Prescaler for lrclk generation from mclk should hold the number of
	// mclk cycles per channel (left and right).

    output reg      mclk,
    output reg      bclk,
	output reg		lrclk,
	output reg		sdata,
	output reg      mute

	// Parallel datastreams
);
reg [AUDIO_DW-1:0]	prescaler = 33;

reg [AUDIO_DW-1:0]		bit_cnt;
reg [AUDIO_DW-1:0]		left;
reg [AUDIO_DW-1:0]		right;
reg [4:0]               clk_cnt;
reg                     clk_tmp;
reg [8:0]               mclk_cnt;



always @(posedge clk or posedge rst) begin
   if (rst == 1) begin
     clk_cnt <= 0;
     clk_tmp <= 0;
     mute <= 1;
   end
   else if(clk_cnt == 9) begin 
     clk_cnt <= 0;
     clk_tmp = ~clk_tmp;
   end
     
   else begin 
     clk_cnt = clk_cnt + 1;
   end
end
   
   
assign mclk = clk_tmp; 

always @(posedge clk_tmp or posedge rst) begin
    if(rst == 1) begin
      mclk_cnt <= 0;
    end
    else begin
      mclk_cnt = mclk_cnt + 1;
    end
end  
   

assign bclk = mclk_cnt[2];





always @(negedge bclk)
	if (rst)
		bit_cnt <= 1;
	else if (bit_cnt >= prescaler)
		bit_cnt <= 1;
	else
		bit_cnt <= bit_cnt + 1;

// Sample channels on the transfer of the last bit of the right channel
always @(negedge bclk)
	if (bit_cnt == prescaler && lrclk) begin
		left <= left_chan;
		right <= right_chan;
	end

// left/right "clock" generation - 0 = left, 1 = right
always @(negedge bclk)
	if (rst)
		lrclk <= 1;
	else if (bit_cnt == prescaler)
		lrclk <= ~lrclk;

always @(negedge bclk)
	sdata <= lrclk ? right[AUDIO_DW - bit_cnt] : left[AUDIO_DW - bit_cnt];

endmodule