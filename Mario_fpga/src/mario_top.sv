`timescale 1ns / 1ps

module mario_top#(OBJECT_SIZE = 20, PIXEL_SIZE = 24 )
    (
    input clk,
    input rst,
    input [2:0] sel,
    input up, down, left, right,
    input [OBJECT_SIZE-1:0] hcount,
    input [OBJECT_SIZE-1:0] vcount,
    output reg [PIXEL_SIZE-1:0] data_out
    );
    
    
    reg [20:0] x_loc;
    reg [20:0] y_loc;
    
    reg [20:0] x_loc_g;
    reg [20:0] y_loc_g;
    
    reg [9:0]  jump;
    reg [9:0]  jump_g;
    reg        right_g;
    reg update;
    reg update_g;
    wire valid_mario;
    wire valid_goomba;
    wire valid_bg;
    wire [PIXEL_SIZE-1:0] data_out_mario;
    wire [PIXEL_SIZE-1:0] data_out_goomba;
    wire [PIXEL_SIZE-1:0] data_out_bg;
    
    struct{
      reg x_loc[9:0];
      reg y_loc[9:0];
    }mem;
    
    
     
    
    //mario display
mario_gen mario_gen_i(
    .clk     (clk     ),
    .rst     (rst     ),
    .sel     (sel     ),
    .hcount  (hcount  ),
    .vcount  (vcount  ),
    .x_loc   (x_loc   ),
    .y_loc   (y_loc   ),
    .valid   (valid_mario   ),
    .data_out(data_out_mario)
);

    //goomba display
goomba_gen goomba_gen_i(
    .clk     (clk     ),
    .rst     (rst     ),
    .sel     (sel     ),
    .hcount  (hcount  ),
    .vcount  (vcount  ),
    .x_loc   (x_loc_g   ),
    .y_loc   (y_loc_g   ),
    .valid   (valid_goomba   ),
    .data_out(data_out_goomba)
);
    
bg_gen bg_gen_i(
    .clk     (clk     ),
    .rst     (rst     ),
    .sel     (sel     ),
    .hcount  (hcount  ),
    .vcount  (vcount  ),
    .valid   (valid_bg   ),
    .data_out(data_out_bg)
);
    
  
    assign data_out = (valid_mario)? data_out_mario :
                      (valid_goomba)? data_out_goomba :
                      (valid_bg)? data_out_bg :
                      24'h8154f7;
    
    
    
    
    
    // moving calculation
    always @(posedge clk or posedge rst ) begin
        if (rst) begin
            x_loc <= 100;
            y_loc <= 100;
        end else begin
            if (vcount == 0 && update == 0 ) begin
                if(jump > 0)   begin 
                    if(y_loc > 2) y_loc <= y_loc - 2; 
                    jump<= jump - 1'b1;
                end else begin
                    if(y_loc < (450 - 16 - 4 )) y_loc <= y_loc + 4;
                    else y_loc <= 450 - 16;
                end
                if ((up == 1'b1) &&(y_loc == 450 - 16)) jump <= 8'h1f;
                if (right)     begin if(x_loc < 600) x_loc <= x_loc + 2; end
                else if (left) begin if(x_loc > 18 )  x_loc <= x_loc - 2; end
                update <= 1;
            end
            if (vcount == 1) begin
                update <=0;
            end
        end
    end
    
        // moving goomba
    always @(posedge clk or posedge rst ) begin
        if (rst) begin
            x_loc_g <= 200;
            y_loc_g <= 450-16;
            right_g <= 1;
        end else begin
            if (vcount == 0 && update_g == 0 ) begin
                if (right_g)     begin 
                    if(x_loc_g < 600) x_loc_g <= x_loc_g + 1;
                    if(x_loc_g == 550) right_g <= 0; 
                    end
                else begin 
                    if(x_loc_g > 18 )  x_loc_g <= x_loc_g - 1; 
                    if(x_loc_g == 150) right_g <= 1; 
                end
                update_g <= 1;
            end
            if (vcount == 1) begin
                update_g <=0;
            end
        end
    end
    
    
endmodule
