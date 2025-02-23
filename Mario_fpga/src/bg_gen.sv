`timescale 1ns / 1ps

module bg_gen(

    input clk,
    input rst,
    input [2:0] sel,
    input [19:0] hcount,
    input [19:0] vcount,
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
    
    
    const reg [0:15][0:15][23:0] bg_obj=
    '{ 
    '{Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,D,Y,Y,Y,D},  
    '{O,O,O,O,O,O,O,O,O,O,O,D,O,O,O,D},  
    '{O,O,O,O,O,O,O,O,O,O,O,D,O,O,O,D},  
    '{O,O,O,O,O,O,O,O,O,O,O,D,O,O,O,D},  
    '{O,O,O,O,O,O,O,O,O,O,O,D,D,D,D,D},  
    '{O,O,O,O,O,O,O,O,O,O,O,D,O,O,O,D},  
    '{O,O,O,O,O,O,O,O,O,O,O,D,O,O,O,D},  
    '{O,O,O,O,O,O,O,O,O,O,D,O,O,O,O,D},  
    '{O,O,O,O,O,O,O,O,O,O,D,O,O,O,O,D},  
    '{O,O,O,O,O,O,O,O,O,D,O,O,O,O,O,D},  
    '{O,O,O,O,O,O,O,O,D,O,O,O,O,O,O,D},  
    '{D,D,O,O,O,O,O,D,O,O,O,O,O,O,O,D},  
    '{O,O,D,D,O,O,O,D,O,O,O,O,O,O,O,D},  
    '{O,O,O,O,D,O,D,O,O,O,O,O,O,O,O,D},  
    '{O,O,O,O,O,D,O,O,O,O,O,O,O,O,O,D},  
    '{D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D}};
  
  
     always @(posedge clk ) begin
        if  (vcount >= 450) begin
            data_out[23 : 0]   <= bg_obj[(vcount-450)/(sel+1)][hcount/(sel+1)];
            valid <= 1'b1;
        end else begin
            valid <= 1'b0;
            data_out <= 24'h000000;
        end
    end  
      
    
    
    
endmodule
