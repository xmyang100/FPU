`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/07 20:52:57
// Design Name: 
// Module Name: INT322FP16_tb
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


module INT322FP16_tb(

    );
    reg [31:0]data_in;
    reg clk;
    reg input_valid;
    reg rst;
    wire output_update;
    wire [15:0]data_out;
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 1;
        input_valid = 1;
        rst = 1;
        data_in = 32'b0000_0000_0000_0000_0101_0101_0101_0101;//out should be 0x7555
        #30 rst = 0;
        #10 data_in = 32'b0000_0000_0000_0000_0011_1100_0011_1100;//out should be 0x7388
        #10 data_in = 32'b1000_1111_0000_0000_0000_1111_1111_1111;//out should be 0xffff
        #10 data_in = 32'b1000_0000_0000_0000_0000_0000_0000_0000;//out should be 0x0000
        #1 input_valid = 0;
        #60 rst = 1;
        
    end
    
    INT322FP16 U1 (
    .data_i(data_in),
    .clk(clk),
    .rst(rst),
    .input_valid(input_valid),
    .data_o(data_out),
    .output_update(output_update)
    );
    
endmodule
