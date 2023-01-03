`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/07 14:58:43
// Design Name: 
// Module Name: fp16_to_fixed
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

//true form
module fp16_to_fixed
(
    input [15:0] float_in,
    input [5:0] scaling_factor,
    input start,
    input clk,
    input rst_n,
    output reg [31:0] fixed_out,
    output done
    );
    
    reg [63:0] fixed_temp;
    reg [63:0] float_in_copy;
    reg sign;
    reg [4:0] shift_count;
    reg shift_direction;
    reg complete;
    reg complete_D1;
    
//    initial done = 1'b1;

    always @(posedge clk or negedge rst_n) 
    begin
        if(!rst_n)
            complete_D1 <= 1'b0;
        else
            complete_D1 <= complete; 
    end
    assign done = (complete && ~complete_D1);
       
    always@(posedge clk) 
    begin
        if(!rst_n) begin
            complete <= 1'b1;
            shift_count <= 8'd0;
            float_in_copy <= 16'd0;
            sign <= 1'b0;
            shift_direction <= 1'b0;
            fixed_temp <= 32'b0;
        end
        else
        if(start) begin
            complete <= 1'b0;
//            shift_count <= 8'd127;
            
            float_in_copy <= {27'd0, 5'd1,float_in[9:0],22'd0};
            shift_count <= float_in[14:10];
            sign <= float_in[15];
            shift_direction <= float_in[14];     
        end
        else if(!complete) begin
            case(shift_direction)
                1'b0: begin
                    if(float_in_copy[31:0] == 32'd0 && shift_count == 5'd0) begin
                        fixed_temp <= 64'd0;
                        complete <= 1'b1;
                    end
                    else begin
                    if(shift_count != 8'd15) begin
                        float_in_copy <= float_in_copy >> 1;
                        shift_count <= shift_count + 1'b1;
                    end
                        else begin
                            complete <= 1'b1;
                            fixed_temp[63] <= sign;
                            fixed_temp[62:32] <= {float_in_copy[63:32]};
                            fixed_temp[31:0] <= {float_in_copy[31:0]};
                        end
                    end
                end
                1'b1: begin
                    if(shift_count != 8'd15) begin
                        float_in_copy <= float_in_copy << 1;
                        shift_count <= shift_count - 1'b1;
                    end
                    else begin
                        complete <= 1'b1;
                        fixed_temp[63] <= sign;
                        fixed_temp[62:32] <= {float_in_copy[63:32]};
                        fixed_temp[31:0] <= {float_in_copy[31:0]};
                    end
                end
            endcase            
        end
    end
    
    always@(*) 
    begin
        fixed_out[31] = fixed_temp[63];
        case(scaling_factor)
            6'd0:       fixed_out[30:0] = fixed_temp[62:32];
            6'd1:       fixed_out[30:0] = fixed_temp[61:31];
            6'd2:       fixed_out[30:0] = fixed_temp[60:30];
            6'd3:       fixed_out[30:0] = fixed_temp[59:29];
            6'd4:       fixed_out[30:0] = fixed_temp[58:28];
            6'd5:       fixed_out[30:0] = fixed_temp[57:27];
            6'd6:       fixed_out[30:0] = fixed_temp[56:26];
            6'd7:       fixed_out[30:0] = fixed_temp[55:25];
            6'd8:       fixed_out[30:0] = fixed_temp[54:24];
            6'd9:       fixed_out[30:0] = fixed_temp[53:23];
            6'd10:      fixed_out[30:0] = fixed_temp[52:22];
            6'd11:      fixed_out[30:0] = fixed_temp[51:21];
            6'd12:      fixed_out[30:0] = fixed_temp[50:20];
            6'd13:      fixed_out[30:0] = fixed_temp[49:19];
            6'd14:      fixed_out[30:0] = fixed_temp[48:18];
            6'd15:      fixed_out[30:0] = fixed_temp[47:17];
            6'd16:      fixed_out[30:0] = fixed_temp[46:16];
            6'd17:      fixed_out[30:0] = fixed_temp[45:15];
            6'd18:      fixed_out[30:0] = fixed_temp[44:14];
            6'd19:      fixed_out[30:0] = fixed_temp[43:13];
            6'd20:      fixed_out[30:0] = fixed_temp[42:12];
            6'd21:      fixed_out[30:0] = fixed_temp[41:11];
            6'd22:      fixed_out[30:0] = fixed_temp[40:10];
            6'd23:      fixed_out[30:0] = fixed_temp[39:9];
            6'd24:      fixed_out[30:0] = fixed_temp[38:8];
            6'd25:      fixed_out[30:0] = fixed_temp[37:7];
            6'd26:      fixed_out[30:0] = fixed_temp[36:6];
            6'd27:      fixed_out[30:0] = fixed_temp[35:5];
            6'd28:      fixed_out[30:0] = fixed_temp[34:4];
            6'd29:      fixed_out[30:0] = fixed_temp[33:3];
            6'd30:      fixed_out[30:0] = fixed_temp[32:2];
            6'd31:      fixed_out[30:0] = fixed_temp[31:1];           
            default:    fixed_out[30:0] = fixed_temp[62:32];            
        endcase
    end
    
endmodule
