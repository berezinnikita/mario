`timescale 1ns / 1ps

module mario_gen(
    input clk,
    input rst,
    input [2:0] sel,
    input [19:0] hcount,
    input [19:0] vcount,
    input [9:0] x_loc,
    input [9:0] y_loc,
    output reg       valid,
    output reg [23:0] data_out
    );
    
    
    
    const reg [23:0] W = 24'hffffff; // white
    const reg [23:0] D = 24'h000000; // dark
    const reg [23:0] R = 24'hbd0808; // red
    const reg [23:0] B = 24'h0300ff; // blue
    const reg [23:0] Y = 24'he8ff00; // yellow
    const reg [23:0] G = 24'h7e9953; // green
    const reg [23:0] O = 24'hd9a739; // orange
    
    
    const reg [0:15][0:15][23:0] mario_obj=
    '{ 
    '{W,W,W,R,R,R,R,R,W,W,W,W,W,W,W,W},   
    '{W,W,R,R,R,R,R,R,R,R,R,W,W,W,W,W}, 
    '{W,W,D,D,D,Y,Y,D,Y,W,W,W,W,W,W,W}, 
    '{W,D,Y,D,Y,Y,Y,D,Y,Y,Y,W,W,W,W,W}, 
    '{W,D,Y,D,D,Y,Y,Y,D,Y,Y,Y,W,W,W,W}, 
    '{W,W,D,Y,Y,Y,Y,D,D,D,D,W,W,W,W,W}, 
    '{W,W,W,Y,Y,Y,Y,Y,Y,W,W,W,W,W,W,W}, 
    '{W,W,R,R,B,R,R,B,R,R,W,W,W,W,W,W}, 
    '{W,R,R,R,B,R,R,B,R,R,R,W,W,W,W,W}, 
    '{R,R,R,R,B,B,B,B,R,R,R,R,W,W,W,W}, 
    '{Y,Y,R,B,Y,B,B,Y,B,R,Y,Y,W,W,W,W}, 
    '{Y,Y,Y,B,B,B,B,B,B,Y,Y,Y,W,W,W,W}, 
    '{Y,Y,B,B,B,B,B,B,B,B,Y,Y,W,W,W,W}, 
    '{W,W,B,B,B,W,W,B,B,B,B,W,W,W,W,W}, 
    '{W,R,R,R,W,W,W,W,R,R,R,W,W,W,W,W}, 
    '{R,R,R,R,W,W,W,W,R,R,R,R,W,W,W,W}};
    
    
    
    always @(posedge clk ) begin
        if ((hcount > (x_loc - 16) && hcount <  (x_loc + 16)) && (vcount > (y_loc - 16 ) && vcount <  (y_loc + 16))) begin
            data_out[23 : 0]   <= mario_obj[(vcount-y_loc - 16)/2][(hcount-x_loc - 16)/2];
            if (mario_obj[(vcount-y_loc - 16)/2][(hcount-x_loc - 16)/2] == W ) valid <= 1'b0;
            else valid <= 1'b1;
        end else begin
            valid <= 1'b0;
            data_out <= 24'hffffff;
        end
    end
    
    
endmodule
