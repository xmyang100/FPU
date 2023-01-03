`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/07 15:23:43
// Design Name: 
// Module Name: fp16_to_fixed_tb
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


module fp16_to_fixed_tb();
    //Parameterized values
    // parameter & = 23;
    // parameter n = 32;
    
    // Inputs    
    reg [15:0] float_in;
    reg [5:0] scaling_factor; 
    reg start; 
    reg clk;
    
    // Outputs
    wire [31:0] fixed_out; 
    wire done;
    
    reg [3:0] count; 
    real top;
    // Instantiate the Unit Under Test (UUT)
    // module Params Name signals 
    fp16_to_fixed uut ( .float_in(float_in),
                        .scaling_factor(scaling_factor), 
                        .start(start),
                        .clk(clk),
                        .fixed_out(fixed_out),
                        .done(done));
    initial begin
        start = 0; 
        clk = 0;
        count = 4'd0; 
        scaling_factor = 6'd16;
        #10 start = 1'b1;
    end
    
    always 
    begin
        #5 clk = ~clk; 
    end
    
    always @ (done) 
    begin
        if(done) begin
            #50 start = 1'b1;
        end 
    end
    
    always @ (start) begin
        if(start) begin
            gen_data(count,float_in);
            #10 start = 1'b0;
            if(count < 4'd15)
                count <= count + 1'b1; 
            else
                count <= count; 
        end
    end

    //Task to generate test data
    task gen_data;
        input [3:0] index;
        output [31:0] float_in;
        
        real top,bottom; 
        begin            
            case(index)
                4'd0: begin
                    //Set float in equals 1.5 
                    float_in[15] = 1'b0;
                    float_in[14:10] = 5'd15;
                    float_in[9:0] = 10'd512; 
                end
                4'd1 :begin
                    //Set float in equals -255 
                    float_in[15] = 1'b1;
                    float_in[14:10] = 5'd22;
                    float_in[9:0] = 10'd1016; 
                end
                4'd2 :begin
                    //Set float in equals 8.125 
                    float_in[15] = 1'b0;
                    float_in[14:10] = 5'd18;
                    float_in[9:0] = 10'd16; 
                end
                4'd3:begin
                    //Set float in equals -10.5 
                    float_in[15] = 1'b1;
                    float_in[14:10]= 5'd18;
                    float_in[9:0] = 10'd320; 
                end
                4'd4 :begin
                    //Set float in equals -32.5 
                    float_in[15] = 1'b1;
                    float_in[14:10] = 5'd20;
                    float_in[9:0] = 10'd16; 
                end
                4'd5 :begin
                    //Set float in equals -0.5
                    float_in[15] = 1'b1;
                    float_in[14:10] = 5'd14; 
                    float_in[9:0] = 10'd0; 
                end
                4'd6:begin
                    //Set float in equals -0.0005 
                    float_in[15] = 1'b1;
                    float_in[14:10] = 5'd4;
                    float_in[9:0] = 8'd24; 
                end
                4'd7:begin
                    //Set float in equals 0.000060976 
                    float_in[15] = 1'b0;
                    float_in[14:10] = 5'd0;
                    float_in[9:0] = 10'd1023; 
                end               
                4'd8:begin
                    //Set float in equals 0.000061035 
                    float_in[15] = 1'b0;
                    float_in[14:10] = 5'd1;
                    float_in[9:0] = 10'd0; 
                end
                
                default:begin
                //Set float in equals 0 
                float_in[15] = 1'b0;
                float_in[14:10] = 5'd0; 
                float_in[9:0] = 10'd0; 
                end
            endcase
        start = 1'b1;
        end
    endtask

endmodule
