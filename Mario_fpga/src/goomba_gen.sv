`timescale 1ns / 1ps

module goomba_gen(
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
    const reg [23:0] G = 24'h7e9953; // D een
    const reg [23:0] O = 24'hd9a739; // orange
    const reg [23:0] Br = 24'h964B00; // brown
    const reg [23:0] Gr = 24'hececec; // gray

    
    
    const reg [0:15][0:15][23:0] goomba_obj=
    '{ 
    '{W ,W ,W ,W ,W ,W ,Br,Br,Br,Br,W ,W ,W ,W ,W ,W },
    '{W ,W ,W ,W ,W ,Br,Br,Br,Br,Br,Br,W ,W ,W ,W ,W },
    '{W ,W ,W ,W ,Br,Br,Br,Br,Br,Br,Br,Br,W ,W ,W ,W },
    '{W ,W ,W ,Br,Br,Br,Br,Br,Br,Br,Br,Br,Br,W ,W ,W },
    '{W ,W ,Br,D ,D ,Br,Br,Br,Br,Br,Br,D ,D ,Br,W ,W },
    '{W ,Br,Br,Br,Gr,D ,Br,Br,Br,Br,D ,Gr,Br,Br,Br,W },
    '{W ,Br,Br,Br,Gr,D ,D ,D ,D ,D ,D ,Gr,Br,Br,Br,W },
    '{Br,Br,Br,Br,Gr,D ,Gr,Br,Br,Gr,D ,Gr,Br,Br,Br,Br},
    '{Br,Br,Br,Br,Gr,Gr,Gr,Br,Br,Gr,Gr,Gr,Br,Br,Br,Br},
    '{Br,Br,Br,Br,Br,Br,Br,Br,Br,Br,Br,Br,Br,Br,Br,Br},
    '{W ,Br,Br,Br,Br,Gr,Gr,Gr,Gr,Gr,Gr,Br,Br,Br,Br,W },
    '{W ,W ,W ,W ,Gr,Gr,Gr,Gr,Gr,Gr,Gr,Gr,W ,W ,W ,W },
    '{W ,W ,W ,W ,Gr,Gr,Gr,Gr,Gr,Gr,Gr,Gr,W ,W ,W ,W },
    '{W ,W ,D ,D ,D ,Gr,Gr,Gr,Gr,Gr,Gr,D ,D ,D ,W ,W },
    '{W ,D ,D ,D ,D ,D ,Gr,Gr,Gr,Gr,D ,D ,D ,D ,D ,W },
    '{W ,D ,D ,D ,D ,D ,D ,W ,W ,D ,D ,D ,D ,D ,D ,W }};
    
    
    
    always @(posedge clk ) begin
        if ((hcount > (x_loc - 16) && hcount <  (x_loc + 16)) && (vcount > (y_loc - 16 ) && vcount <  (y_loc + 16))) begin
            data_out[23 : 0]   <= goomba_obj[(vcount-y_loc - 16)/2][(hcount-x_loc - 16)/2];
            if (goomba_obj[(vcount-y_loc - 16)/2][(hcount-x_loc - 16)/2] == W ) valid <= 1'b0;
            else valid <= 1'b1;
        end else begin
            valid <= 1'b0;
            data_out <= 24'hffffff;
        end
    end
    
    
endmodule
