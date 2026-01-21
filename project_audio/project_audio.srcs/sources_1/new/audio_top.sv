`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2025 10:53:40 PM
// Design Name: 
// Module Name: audio_top
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


module audio_top#(parameter AUDIO_DW = 33)
( 
    input clk,
    input rst,
  
    input [3:0] btn,
    
    output reg      mclk,
    output reg      bclk,
	output reg		lrclk,
	output reg		sdata,
	output reg      mute
);


  // First octave (C4 - B4)
  parameter C4  = 3831;  // 261 Hz  - Middle C
  parameter C4S = 3610;  // 277 Hz  - C# / Db
  parameter D4  = 3413;  // 293 Hz
  parameter D4S = 3215;  // 311 Hz  - D# / Eb
  parameter E4  = 3037;  // 329 Hz
  parameter F4  = 2865;  // 349 Hz
  parameter F4S = 2703;  // 370 Hz  - F# / Gb
  parameter G4  = 2551;  // 392 Hz
  parameter G4S = 2410;  // 415 Hz  - G# / Ab
  parameter A4  = 2273;  // 440 Hz  - Concert A
  parameter A4S = 2145;  // 466 Hz  - A# / Bb
  parameter B4  = 2025;  // 493 Hz

  // Second octave (C5 - B5)
  parameter C5  = 1912;  // 523 Hz
  parameter C5S = 1805;  // 554 Hz
  parameter D5  = 1706;  // 587 Hz
  parameter D5S = 1610;  // 622 Hz
  parameter E5  = 1525;  // 659 Hz
  parameter F5  = 1433;  // 698 Hz
  parameter F5S = 1351;  // 740 Hz
  parameter G5  = 1275;  // 784 Hz
  parameter G5S = 1205;  // 831 Hz
  parameter A5  = 1136;  // 880 Hz
  parameter A5S = 1073;  // 932 Hz
  parameter B5  = 1014;  // 987 Hz
  parameter REST = 0;

/*
parameter [31:0] mario_notes [0:60] = {
E5,E5,0,E5,0,C5,E5, //7
G5,0,0,G4,0,0,      //6
C5,0,G4,0,0,E4,     //6
E4,A4,B4,A4S,A4,    //5
G4,E5,G5,A5,F5,G5,   //6  1-line 30
0,E5,C5,D5,B4,       //5 
C5,G4,0,0,E4,        //5
E4,A4,B4,B4,A4,      //5
G4,E5,G5,A5,F5,G5,   //6
0,E5,C5,D5,B4,       //5  2-line 26
0,0,0,0,0}; 
*/

  parameter [31:0] mario_notes [0:60] = {
    {E5 ,16'd500}, {E5 ,16'd500}, {REST,16'd500}, {E5 ,16'd500}, {REST,16'd500}, {C5 ,16'd500}, {E5 ,16'd500},
    {G5 ,16'd500}, {REST,16'd500}, {REST,16'd500}, {G4 ,16'd500}, {REST,16'd500}, {REST,16'd500},
    {C5 ,16'd500}, {REST,16'd500}, {G4 ,16'd500}, {REST,16'd500}, {REST,16'd500}, {E4 ,16'd500},
    {E4 ,16'd500}, {A4 ,16'd500}, {B4 ,16'd500}, {A4S,16'd500}, {A4 ,16'd500},
    {G4 ,16'd500}, {E5 ,16'd500}, {G5 ,16'd500}, {A5 ,16'd500}, {F5 ,16'd500}, {G5 ,16'd500},
    {REST,16'd500}, {E5 ,16'd500}, {C5 ,16'd500}, {D5 ,16'd500}, {B4 ,16'd500},
    {C5 ,16'd500}, {G4 ,16'd500}, {REST,16'd500}, {REST,16'd500}, {E4 ,16'd500},
    {E4 ,16'd500}, {A4 ,16'd500}, {B4 ,16'd500}, {B4 ,16'd500}, {A4 ,16'd500},
    {G4 ,16'd500}, {E5 ,16'd500}, {G5 ,16'd500}, {A5 ,16'd500}, {F5 ,16'd500}, {G5 ,16'd500},
    {REST,16'd500}, {E5 ,16'd500}, {C5 ,16'd500}, {D5 ,16'd500}, {B4 ,16'd500},
    {REST,16'd500}, {REST,16'd500}, {REST,16'd500}, {REST,16'd500}, {REST,16'd500}
  };


  reg [AUDIO_DW-1:0]	left_chan;
  reg [AUDIO_DW-1:0]	right_chan;
  reg [17:0]            clk_cnt;
  reg                   chan_clk;
  reg [15:0]            sound_cnt;
  reg [12:0]            delay;
  reg [20:0]            note_cnt;
  reg                   note_clk;
  reg                   end_note;
  
// I2S TX instance
i2s_tx  #(.AUDIO_DW(AUDIO_DW)) i2s_tx_inst (
    .clk(clk),
    .rst(rst),
    
    .left_chan(left_chan),
    .right_chan(right_chan),
  
  
    .mclk(mclk),
    .bclk(bclk),
    .lrclk(lrclk),
    .sdata(sdata),
    .mute(mute)
);



always @(posedge clk or posedge rst) begin
   if (rst == 1) begin
     clk_cnt <= 0;
   end
   else begin 
     clk_cnt = clk_cnt + 1;
   end
end

assign chan_clk = clk_cnt[6];// 1MHz
/*
always @(posedge clk or posedge rst) begin
   if (rst == 1) begin
     delay <= 0;
   end
   else begin 
     delay[10:6] <= {btn, 1'b1};
   end
end
*/

always @(posedge chan_clk or posedge rst) begin
    if(rst == 1) begin
      sound_cnt <= 0;
      left_chan <= 8;
      right_chan <= 8;
    end
    else begin
      if( (delay == 0) || (end_note == 1)) begin
        left_chan[22:0] <= 'h00_0000;
      end 
      else if (sound_cnt <= (delay/2)) begin
        left_chan[22:0] <='h20_0000;// -  (sound_cnt*(16384-(delay*8)));
        sound_cnt <= sound_cnt + 1;
      end
      else if(sound_cnt <= delay) begin
        left_chan[22:0] <= 'h00_0000;// - ((delay - sound_cnt) *(16384-(delay*8)));
        sound_cnt <= sound_cnt + 1;
      end else begin 
        sound_cnt <= 0;
      end
    end
end


always @(posedge chan_clk or posedge rst) begin
   if (rst == 1) begin
     note_cnt <= 0;
     end_note <= 0;
   end
   else if(note_cnt <= 'h20000) begin 
     note_cnt = note_cnt + 1;
     if(note_cnt > 'h1e000) begin
       end_note <= 1;
     end  
   end
   else begin
     note_cnt <= 0;
     note_clk <= ~note_clk;
     end_note <= 0;
   end
end


int note_sel;
always @(posedge note_clk or posedge rst) begin
   if (rst == 1) begin
     delay <= 'h100;
     note_sel <= 0;
   end
   else begin 
     note_sel <=(note_sel == 60) ? 0 : note_sel + 1;
     delay <= mario_notes[note_sel][31:16];
   end
end
/*
always @(posedge note_clk or posedge rst) begin
   if (rst == 1) begin
     delay <= 'h100;
   end
   else if(delay <= 'h800) begin 
     delay<= delay + 32;
   end else begin
     delay <= 'h100;
   end
end
*/






endmodule



