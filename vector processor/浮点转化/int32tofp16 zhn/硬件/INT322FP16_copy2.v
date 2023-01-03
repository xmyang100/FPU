`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/04 16:12:38
// Design Name: 
// Module Name: INT322FP16
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


module INT322FP16(
    input data_i,
    input clk,
    input input_valid,
    input rst,
    output output_update,
    output data_o
    );
    
    wire [31:0] data_i;
    wire clk;
    wire rst;               //high level active
    wire input_valid;       //high level active
    reg [15:0]data_o;
    reg output_update;
    
    reg [3:0] first_one_index;
    reg sign1;                  //for step1:pre_operation
    reg [11:0]rmcache1;
    reg ifoverflow;
    reg ifzero;
    reg ifround;
    reg pre_over;
    reg round_over;         //for step2:round to nearest even
    reg sign2;
    reg [11:0]rmcache2;
    reg [5:0]expcache2;
    reg ifoverflow2;
    reg ifzero2;
    reg carry_over;         //for step3:overflow and carry
    reg sign3;
    reg [11:0]rmcache3;
    reg [5:0]expcache3;
    reg ifoverflow3;
    reg ifzero3;
    
    always@(posedge clk or posedge rst) begin       //step1:pre_operation
        if(rst) begin
            first_one_index <= 5'd0;
            ifoverflow <= 1'b0;
            ifzero <= 1'b0;
            ifround <= 1'b0;
            sign1 <= 1'b0;
            rmcache1 <= 16'd0;   
            pre_over <= 1'b0;      
        end
        else if(input_valid)    begin
            pre_over <= 1'b1;
            sign1 <= data_i[31];
            casex(data_i[30:0])
                31'b000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx : begin
                    first_one_index <= 5'd15;
                    rmcache1 <= data_i[16:5];
                    ifround <= data_i[4] && (data_i[5] || (|data_i[3:0]));
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;   
                end
                31'b000_0000_0000_0000_01xx_xxxx_xxxx_xxxx : begin 
                    first_one_index <= 5'd14; 
                    rmcache1 <= data_i[15:4];
                    ifround <= data_i[3] && (data_i[4] || (|data_i[2:0]));
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;               
                end
                31'b000_0000_0000_0000_001x_xxxx_xxxx_xxxx : begin 
                    first_one_index <= 5'd13; 
                    rmcache1 <= data_i[14:3];
                    ifround <= data_i[2] && (data_i[3] || (|data_i[1:0]));
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;  
                end
                31'b000_0000_0000_0000_0001_xxxx_xxxx_xxxx : begin 
                    first_one_index <= 5'd12; 
                    rmcache1 <= data_i[13:2];
                    ifround <= data_i[1] && (data_i[2] || data_i[0]);
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_1xxx_xxxx_xxxx : begin 
                    first_one_index <= 5'd11; 
                    rmcache1 <= data_i[12:1];
                    ifround <= data_i[0] && data_i[1];
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_01xx_xxxx_xxxx : begin 
                    first_one_index <= 5'd10; 
                    rmcache1 <= data_i[11:0];
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_001x_xxxx_xxxx : begin 
                    first_one_index <= 5'd9; 
                    rmcache1 <= {data_i[10:0],1'b0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_0001_xxxx_xxxx : begin 
                    first_one_index <= 5'd8; 
                    rmcache1 <= {data_i[9:0],2'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_0000_1xxx_xxxx : begin 
                    first_one_index <= 5'd7; 
                    rmcache1 <= {data_i[8:0],3'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;   
                end
                31'b000_0000_0000_0000_0000_0000_01xx_xxxx : begin 
                    first_one_index <= 5'd6; 
                    rmcache1 <= {data_i[7:0],4'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_0000_001x_xxxx : begin 
                    first_one_index <= 5'd5; 
                    rmcache1 <= {data_i[6:0],5'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_0000_0001_xxxx : begin 
                    first_one_index <= 5'd4; 
                    rmcache1 <= {data_i[5:0],6'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0; 
                end
                31'b000_0000_0000_0000_0000_0000_0000_1xxx : begin 
                    first_one_index <= 5'd3; 
                    rmcache1 <= {data_i[4:0],7'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_0000_0000_01xx : begin 
                    first_one_index <= 5'd2;
                    rmcache1 <= {data_i[3:0],8'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_0000_0000_001x : begin 
                    first_one_index <= 5'd1; 
                    rmcache1 <= {data_i[2:0],9'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;
                end
                31'b000_0000_0000_0000_0000_0000_0000_0001 : begin 
                    first_one_index <= 5'd0; 
                    rmcache1 <= {data_i[1:0],10'd0};
                    ifround <= 1'b0;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b0;  
                end
                31'b000_0000_0000_0000_0000_0000_0000_0000 : begin 
                    first_one_index <= first_one_index; 
                    rmcache1 <= rmcache1;
                    ifround <= ifround;
                    ifoverflow <= 1'b0;
                    ifzero <= 1'b1;   
                end
                default : begin 
                    first_one_index <= first_one_index; 
                    rmcache1 <= rmcache1;
                    ifround <= ifround;
                    ifoverflow <= 1'b1;
                    ifzero <= 1'b0;   
                end
            endcase
        end
        else    begin
            pre_over <= 1'b0;
            ifoverflow <= ifoverflow;
            ifzero <= ifzero;
            ifround <= ifround;
            sign1 <= sign1;
            rmcache1 <= rmcache1;  
            first_one_index <= first_one_index; 
        end
    end
    
    always @ (posedge clk or posedge rst)   begin       //step2:round to nearest even
        if(rst) begin
            round_over <= 1'b0;
            sign2 <= 1'b0;
            rmcache2 <= 11'd0;
            expcache2 <= 11'd0;
        end
        else if(pre_over)   begin
            round_over <= 1'b1;
            sign2 <= sign1;
            ifoverflow2 <= ifoverflow;
            ifzero2 <= ifzero;
            if(~(ifoverflow | ifzero))
                expcache2 <= first_one_index + 6'd15;
            else 
                expcache2 <= expcache2;
            rmcache2 <= ifround ? rmcache1 + 12'd1 : rmcache1;        
        end
        else    begin
            round_over <= 1'b0;
            sign2 <= sign2;
            rmcache2 <= rmcache2;
            expcache2 <= expcache2;
            ifoverflow2 <= ifoverflow2;
            ifzero2 <= ifzero2;
        end
    end
    
    always @ (posedge clk or posedge rst)   begin           //step3:overflow and carry
        if(rst) begin
            carry_over <= 1'b0;
            sign3 <= 1'b0;
            rmcache3 <= 10'd0;
            expcache3 <= 6'd0;
            ifzero3 <= 1'b0;
            ifoverflow3 <= 1'b0;
        end
        else if(round_over) begin
            carry_over <= 1'b1;
            sign3 <= sign2;
            ifzero3 <= ifzero2;
            ifoverflow3 <= ifoverflow2;
            if(rmcache2[11])    begin
                rmcache3 <= rmcache2 >> 1;
                expcache3 <= expcache2 + 6'd1;
            end
            else    begin
                rmcache3 <= rmcache2;
                expcache3 <= expcache2;
            end          
        end
        else    begin
            carry_over <= 1'b0;
            sign3 <= sign3;
            rmcache3 <= rmcache3;
            expcache3 <= expcache3;
            ifzero3 <= ifzero3;
            ifoverflow3 <= ifoverflow3;
        end
    end
    
    always@(posedge clk or posedge rst)   begin     //result
        if(rst) begin
            data_o <= 16'd0;
            output_update <= 1'b0;
        end
        else if(carry_over) begin
            output_update <= 1'b1;
            if(ifoverflow3 && ~ifzero3)
                data_o <= 16'hffff;
            else if(~ifoverflow3 && ifzero3)
                data_o <= 16'h0000;
            else begin
                if(expcache3 < 31)
                    data_o <= {sign3,expcache3[4:0],rmcache3[9:0]};
                else
                    data_o <= 16'hffff;
            end
        end
        else    begin
            output_update <= 1'b0;
            data_o <= data_o;
        end
    end
    
    
    
endmodule
