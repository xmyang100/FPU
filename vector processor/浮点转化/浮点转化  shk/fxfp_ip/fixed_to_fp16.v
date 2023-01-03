`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/29 16:25:44
// Design Name: 
// Module Name: fixed_to_fp16
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


module fixed_to_fp16#(
    parameter Q = 23,
    parameter N = 32
)
(
    input [N-1:0] fixed_in,
    input [5:0] scaling_factor,
    input start,
    input clk,
    input rst_n,
    output [15:0] float_out,
    output done
    );
    
    reg [15:0] float_temp;
    reg [N-1:0] fixed_in_copy;
    reg sign;
    reg [4:0] shift_count;
    reg shift_direction;
    reg complete;
    reg complete_D1;
    
    wire [31:0] max_value;
    
    assign max_value = 31'd65504 << scaling_factor;
    
//    initial complete = 1'b0;
    
    assign float_out = float_temp;
    
    always @(posedge clk or negedge rst_n) 
    begin
        if(!rst_n)
            complete_D1 <= 1'b0;
        else
            complete_D1 <= complete; 
    end
    assign done = (complete && ~complete_D1);
    
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n) begin
            complete <= 1'b1;
            shift_count <= 5'd0;
            fixed_in_copy <= {N{1'b0}};
            sign <= 1'b0;
            shift_direction <= 1'b0;
            float_temp <= 16'b0;
        end    
        else 
        if(start) begin
            complete <= 1'b0;
            shift_count <= 5'd0;
            
            fixed_in_copy <= {1'b0,fixed_in[N-2:0]};
            sign <= fixed_in[N-1];
            shift_direction <= | fixed_in[N-2:N-6];           
        end
        else if(!complete) begin
            case(shift_direction)
                1'b0: begin
                    if(fixed_in_copy == 32'd0) begin
                        float_temp <= 16'd0;
                        complete <= 1'b1;
                    end
                    else if(fixed_in[31:0] > max_value) begin
                        float_temp[15] <= sign;
                        float_temp[14:0] <= 15'b111_1011_1111_1111;
                        complete <= 1'b1; 
                    end
                    else begin
                        if(fixed_in_copy[26]==1'b0) begin
                            fixed_in_copy <= fixed_in_copy << 1;
                            shift_count <= shift_count + 1'b1;
                        end
                        else begin
                            complete <= 1'b1;
                            float_temp[15] <= sign;
                            float_temp[14:10] <= 6'd41 - scaling_factor - shift_count;
                            float_temp[9:0] <= fixed_in_copy [25:16];
                        end
                    end
                end
                
                1'b1 : begin
                    if(fixed_in[31:0] > max_value) begin
                        float_temp[15] <= sign;
                        float_temp[14:0] <= 15'b111_1011_1111_1111;
                        complete <= 1'b1; 
                    end
                    else if(fixed_in_copy[30:27] != 4'b0000) begin
                        fixed_in_copy <= fixed_in_copy >> 1;
                        shift_count <= shift_count + 1;
                    end
                    else begin
                        complete <= 1'b1;
                        float_temp[15] <= sign;
                        float_temp[14:10] <= 6'd41 - scaling_factor + shift_count;
                        float_temp[9:0] <= fixed_in_copy[9:0];
                    end
                end
            endcase
        end
        else begin
            shift_count <= 5'd0;
        end
    end
    
endmodule
