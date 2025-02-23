`timescale 1ns / 1ps




////////////////////////////////////////////////////////////////////////
module HDMI_test(
	input clk,  // 125MHz
	input rst,
	output [2:0] TMDSp, TMDSn,
	output TMDSp_clock, TMDSn_clock
);

 
    reg [3:0] cnt;
    wire pixclk;
    wire DCM_pixclk;
    
    
    
    /*
    always@(posedge clk or posedge rst) begin
      if(rst) begin
        cnt <= 0;
        pixclk<= 'b0;
      end else begin
        if(cnt == 'h4) begin
          pixclk <= ~pixclk;
          cnt <= 0;
        end else begin
          cnt<= cnt + 1'b1;  
        end
      end 
      end
    */
    
    
    DCM_SP #(.CLKDV_DIVIDE(5)) DCM_TMDS_inst_div(.CLKIN(clk), .CLKDV(DCM_pixclk), .RST(0));
    BUFG BUFG_pixel_clock(.I(DCM_pixclk), .O(pixclk));
    
////////////////////////////////////////////////////////////////////////
reg [9:0] CounterX = 0, CounterY = 0;
reg hSync, vSync, DrawArea;
always @(posedge pixclk or posedge rst) if (rst) DrawArea <=0; else  DrawArea <= (CounterX<640) && (CounterY<480);

always @(posedge pixclk or posedge rst)begin
 if(rst) CounterX <= 0;
 else CounterX <= (CounterX==799) ? 0 : CounterX+1;
 end
always @(posedge pixclk or posedge rst) 
if (rst) CounterY <= 0;
else if(CounterX==799) CounterY <= (CounterY==524) ? 0 : CounterY+1;

always @(posedge pixclk or posedge rst) if (rst) hSync <= 0; 
    else hSync <= (CounterX>=656) && (CounterX<752);
    
always @(posedge pixclk or posedge rst) if (rst) vSync <= 0;
else  vSync <= (CounterY>=490) && (CounterY<492);

////////////////
wire [7:0] W = {8{CounterX[7:0]==CounterY[7:0]}};
wire [7:0] A = {8{CounterX[7:5]==3'h2 && CounterY[7:5]==3'h2}};
reg [7:0] red, green, blue;
always @(posedge pixclk or posedge rst)if (rst) red <=0; else red <= ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00} | W) & ~A;
always @(posedge pixclk or posedge rst)if (rst) green <=0; else green <= (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
always @(posedge pixclk or posedge rst)if (rst) blue <=0; else blue <= CounterY[7:0] | W | A;

////////////////////////////////////////////////////////////////////////
wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
TMDS_encoder encode_R(.clk(pixclk), .rst(rst), .VD(red  ), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_red));
TMDS_encoder encode_G(.clk(pixclk), .rst(rst), .VD(green), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_green));
TMDS_encoder encode_B(.clk(pixclk), .rst(rst), .VD(blue ), .CD({vSync,hSync}), .VDE(DrawArea), .TMDS(TMDS_blue));

////////////////////////////////////////////////////////////////////////
wire clk_TMDS, DCM_TMDS_CLKFX;  // 25MHz x 10 = 250MHz
DCM_SP #(.CLKFX_MULTIPLY(2)) DCM_TMDS_inst(.CLKIN(clk), .CLK2X(DCM_TMDS_CLKFX), .RST(0));
BUFG BUFG_TMDSp(.I(DCM_TMDS_CLKFX), .O(clk_TMDS));

////////////////////////////////////////////////////////////////////////
reg [3:0] TMDS_mod10=0;  // modulus 10 counter
reg [9:0] TMDS_shift_red=0, TMDS_shift_green=0, TMDS_shift_blue=0;
reg TMDS_shift_load=0;
always @(posedge clk_TMDS or posedge rst)if (rst) TMDS_shift_load <=0; else TMDS_shift_load <= (TMDS_mod10==4'd8);

reg new_clk;

always @(posedge clk_TMDS or posedge rst)
if (rst) begin
	TMDS_shift_red   <= 0;
	TMDS_shift_green <= 0;
	TMDS_shift_blue  <= 0;	
	TMDS_mod10 <= 0;
end else begin
	TMDS_shift_red   <= TMDS_shift_load ? TMDS_red   : TMDS_shift_red  [9:1];
	TMDS_shift_green <= TMDS_shift_load ? TMDS_green : TMDS_shift_green[9:1];
	TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue  : TMDS_shift_blue [9:1];
	if(pixclk == 1'b0) begin
	   if (new_clk == 1'b0) begin
	       new_clk <= 1'b1;
	       TMDS_mod10 <= 4'd0;
	   end else begin
	       TMDS_mod10 <= TMDS_mod10+4'd1;
	   end 
	end else begin
	   new_clk <= 1'b0;
	   TMDS_mod10 <= TMDS_mod10+4'd1;
	end
end

OBUFDS OBUFDS_red  (.I(TMDS_shift_red  [0]), .O(TMDSp[2]), .OB(TMDSn[2]));
OBUFDS OBUFDS_green(.I(TMDS_shift_green[0]), .O(TMDSp[1]), .OB(TMDSn[1]));
OBUFDS OBUFDS_blue (.I(TMDS_shift_blue [0]), .O(TMDSp[0]), .OB(TMDSn[0]));
OBUFDS OBUFDS_clock(.I(pixclk), .O(TMDSp_clock), .OB(TMDSn_clock));
endmodule


////////////////////////////////////////////////////////////////////////
module TMDS_encoder(
	input clk,
	input rst,
	input [7:0] VD,  // video data (red, green or blue)
	input [1:0] CD,  // control data
	input VDE,  // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
	output reg [9:0] TMDS = 0
);

reg [9:0] TMDS_code;

wire [3:0] Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
wire XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && VD[0]==1'b0);
wire [8:0] q_m = {~XNOR, q_m[6:0] ^ VD[7:1] ^ {7{XNOR}}, VD[0]};

reg [3:0] balance_acc = 0;
wire [3:0] balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
wire balance_sign_eq = (balance[3] == balance_acc[3]);
wire invert_q_m = (balance==0 || balance_acc==0) ? ~q_m[8] : balance_sign_eq;
wire [3:0] balance_acc_inc = balance - ({q_m[8] ^ ~balance_sign_eq} & ~(balance==0 || balance_acc==0));
wire [3:0] balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc+balance_acc_inc;
wire [9:0] TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};

always @(posedge clk or posedge rst)begin
    if (rst) TMDS_code <= 0;
    else begin
        case (CD) 
            2'b00 :   TMDS_code <= 10'b1101010101;
            2'b01 :   TMDS_code <= 10'b0010101010;
            2'b10 :   TMDS_code <= 10'b0010101011;
            2'b11 :   TMDS_code <= 10'b1101010100;
        endcase
    end
end

always @(posedge clk or posedge rst)if (rst) TMDS <=0; else TMDS <= VDE ? TMDS_data : TMDS_code;
always @(posedge clk or posedge rst)if (rst) balance_acc <=0; else balance_acc <= VDE ? balance_acc_new : 4'h0;
endmodule

