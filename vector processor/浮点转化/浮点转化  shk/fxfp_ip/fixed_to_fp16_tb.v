`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/29 21:25:53
// Design Name: 
// Module Name: fixed_to_fp16_tb
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


module fixed_to_fp16_tb(); 
    //Parameterized values 
    parameter Q = 8; 
    parameter N = 32;
    // Inputs
    reg [N-1:0] fixed_in;
    reg start; 
    reg [5:0] scaling_factor;
    reg clk;
    // outputs
    wire [15:0] float_out; 
    wire done;
    reg [3:0] count; 
    real top;
    
    wire sign;
    wire [4:0] E;
    wire [9:0] M;
    
    assign sign = float_out[15];
    assign E = float_out[14:10];
    assign M = float_out[9:0];
    
    //Instantiate the Unit Under Test (UUT)
    //module Params Name Siqnals 
    fixed_to_fp16 #(Q,N) u_fixed_to_fp16 (  .fixed_in(fixed_in), 
                                            .scaling_factor(scaling_factor),
                                            .start(start),
                                            .clk(clk),
                                            .float_out(float_out),
                                            .done(done));
    initial begin
        start = 0; 
        clk = 0;
        count = 4'd0;
        scaling_factor = 6'd8;
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
    
    always @ (start) 
    begin
        if(start) begin
            gen_data(count,fixed_in);
            #10 start = 1'b0;
            if(count < 4'd15)
                count <= count + 1'b1; 
            else
                count <= count;
        end 
    end
/*
Task to convert from rational to fixed point*/
task conv_rational;
    input real num;
    output [N-1:0] fixed;
    integer i; 
    real tmp;
    begin
        tmp = num;
        
        //set sign
        if(tmp < 0) begin
        //if its negative, set the sign bit and make the temporary number
        //position by multiplying by -1
            fixed[N-1] =1; 
            tmp =tmp * -1; 
        end
        else begin
        //if its positive, the sign bit is zero
            fixed[N-1] =0; 
        end

        //check that the number isnt too large 
        if(tmp > (1 << N-Q-1)) begin
            $display("Error!!! rational number %f is larger than %d whole bits can represent!",num,N-Q-1);
        end
        //set whole part
        for(i=0;i<N-Q-1; i=i+1) begin
            if(tmp >= (1 << N-Q-2-i)) begin
            //if its greater or equal, subtract out this power of 2 and
            //put a one at this position
                fixed[N-2-i] =1;
                tmp = tmp - (1 << N-Q-2-i); 
            end
        else begin
        //if its less, put a zero at this position
            fixed[N-2-i] = 0; 
        end 
    end
    
    //set fractional part
    for(i=1; i<=Q; i=i+1) begin
        if(tmp >= 1.0/(1 << i)) begin
        //if its greater or equal, subtract out this power of 2 and
        //put a one at this position
            fixed[Q-i] = 1;
            tmp = tmp - 1.0/(1 << i); 
        end
        else begin
        //if its less, put a zero at this position
            fixed[Q-i] =0; 
        end 
    end
    //check that the number isnt too small (loss of precision) 
    if(tmp > 0) begin
        $display("Error!!! LOSS OF PRECISION converting rational number %f's fractional part using od bits!", num,Q); 
        end 
    end
endtask

/*
Task to generate test data
*/
task gen_data;
    input [3:0] index;
    output [N-1:0] fixed_in;
    real top,bottom; 
    begin        
        case(index)
            4'd0: begin
                // Initialize Inputs 
                top = 1.5;
                conv_rational(top,fixed_in);
            end
            4'd1: begin
                // Initialize Inputs 
                top = 8388607;
                conv_rational(top,fixed_in); 
            end
            4'd2 :begin
                // Initialize Inputs 
                top = 8.125;
                conv_rational(top,fixed_in); 
            end
            4 'd3:begin
                // Initialize Inputs 
                top = -10.5;
                conv_rational(top,fixed_in); 
            end
            4 'd4 :begin
                // Initialize Inputs 
                top = -0.5;
                conv_rational(top,fixed_in); 
            end
            4'd5 :begin
                // Initialize Inputs 
                top = 0.25;
                conv_rational(top,fixed_in); 
            end
            4'd6:begin
                // Initialize Inputs 
                top = -0.005;
                conv_rational(top,fixed_in); 
            end
            
            default:begin
                // Initialize Inputs 
                top =-32.5;
                conv_rational(top,fixed_in); 
            end
        endcase
        //#20 start = 1'b0; 
    end
endtask

endmodule
