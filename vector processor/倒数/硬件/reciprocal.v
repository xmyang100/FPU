`timescale 1ps/1ps

module reciprocal(divisor,divisor_valid,rst,clk,result,complete);

input wire [15:0]divisor;
input wire divisor_valid;
input clk;
input rst;

output wire [15:0]divisor;
output wire complete;

parameter IDLE = 3'b000;
parameter EXP_PROCESS = 3'b001;
parameter Q_SEARCH = 3'b010;
parameter W_COMPUTE = 3'b011;
parameter ON_THE_FLY_CONVERSION = 3'b100;


always @(*)
begin
    case(state)
        IDLE:
        begin
            if(divisor_valid)
                STATE = EXP_PROCESS
            else
                STATE = IDLE
        end
        EXP_PROCESS:
        begin
            if()
        end
    


    endcase
end


always @(posedge clk)
begin
    if(rst)
        state <= IDLE;
    else
        state <= STATE;
end


endmodule