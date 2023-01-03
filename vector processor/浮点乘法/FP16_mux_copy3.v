`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/01 23:03:31
// Design Name: 
// Module Name: FP16_mux
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


module FP16_mux(
    input data1,
    input data2,
    input rst,
    input input_valid,
    input clk,
    output datanew,
    output output_update
    );
    
    wire clk;
    wire [15:0] data1;
    wire [15:0] data2; 
    wire rst;
    wire input_valid;
    reg [15:0] datanew;
    reg output_update;
     
    reg [21:0]rmcache1;     //for step1:calculate
    reg signed[6:0]expcache1;
    reg cal_over;
    reg sign1;
    reg [21:0]rmcache2;     //for step2:overflow
    reg signed[6:0]expcache2;
    reg sign2;
    reg carry1_over;           
    reg lastbit;            
    reg [21:0]rmcache3;     //for step3:round to nearest even
    reg signed[6:0]expcache3;
    reg sign3;
    reg round_over;
    reg [21:0]rmcache4;     //for step4:overflowagain
    reg signed[6:0]expcache4;
    reg sign4;
    reg carry2_over;
    
    always@(posedge clk or posedge rst) begin       //calculate
        if(rst) begin
            rmcache1 <= 22'd0;
            expcache1 <= 7'd0;
            cal_over <= 1'b0;
            sign1 <= 1'b0;
        end
        else if(input_valid)    begin
            rmcache1 <= {1'b1,data1[9:0]} * {1'b1,data2[9:0]};
            expcache1 <= data1[14:10] + data2[14:10] - 6'd15;
            cal_over <= 1'b1;
            sign1 <= data1[15] & data2[15];
        end
        else    begin
            rmcache1 <= rmcache1;
            expcache1 <= expcache1;
            cal_over <= 1'b0;
            sign1 <= sign1;
        end        
    end
    
    always@(posedge clk or posedge rst) begin       //overflow and carry
        if(rst) begin
            rmcache2 <= 22'd0;
            expcache2 <= 7'd0;
            lastbit <= 1'b0;
            carry1_over <= 1'b0;
            sign2 <= 1'b0;
        end
        else if(cal_over)   begin
            sign2 <= sign1;
            if(rmcache1[21])    begin
                rmcache2 <= rmcache1 >> 1;
                expcache2 <= expcache1 + 6'd1;
            end
            else    begin
                rmcache2 <= rmcache1;
                expcache2 <= expcache1;
            end
            lastbit <= rmcache1[0];
            carry1_over <= 1'b1;
        end
        else    begin
            rmcache2 <= rmcache2;
            expcache2 <= expcache2;
            lastbit <= lastbit;
            carry1_over <= 1'b0;
            sign2 <= sign2;
        end
    end
    
    always@(posedge clk or posedge rst) begin       //round to nearest even
        if(rst) begin
            rmcache3 <= 22'd0;
            expcache3 <= 7'd0;
            round_over <= 1'b0;
            sign3 <= 1'b0;
        end
        else if(carry1_over)    begin
            expcache3 <= expcache2;
            sign3 <= sign2;
            if( rmcache2[9] && ( rmcache2[10] || (|rmcache2[8:0]) || lastbit) )
                rmcache3 <= rmcache2 + 22'h000400;
            else
                rmcache3 <= rmcache2;
            round_over <= 1'b1;
        end
        else    begin
            rmcache3 <= rmcache3;
            expcache3 <= expcache3;
            sign3 <= sign3;
            round_over <= 1'b0;
        end
    end
    
    always@(posedge clk or posedge rst) begin       //overflow again
        if(rst) begin
            rmcache4 <= 22'd0;
            expcache4 <= 7'd0;
            carry2_over <= 1'b0;
            sign4 <= 1'b0;
        end
        else if(round_over)   begin
            sign4 <= sign3;
            if(rmcache3[21])    begin
                rmcache4 <= rmcache3 >> 1;
                expcache4 <= expcache3 + 6'd1;
            end
            else    begin
                rmcache4 <= rmcache3;
                expcache4 <= expcache3;
            end
            carry2_over <= 1'b1;
        end
        else    begin
            sign4 <= sign4;
            rmcache4 <= rmcache4;
            expcache4 <= expcache4;
            carry2_over <= 1'b0;
        end
    end
    
    always@(posedge clk or posedge rst) begin   //result
        if(rst) begin
            datanew <= 16'd0;
            output_update <= 1'b0;
        end
        else if(carry2_over)    begin
            if(expcache4 > 7'd31)           //upon overflow
                datanew <= {sign4,15'h7ff};
            else if(expcache4 >= 0)
                datanew <= {sign4,expcache4[4:0],rmcache4[19:10]};
            else
                datanew <= {sign4,15'h000}; //down overflow
            output_update <= 1'b1;
        end
        else    begin
            datanew <= datanew;
            output_update <= 1'b0; 
        end
    end

endmodule
