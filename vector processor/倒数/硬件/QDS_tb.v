`timescale 1ps/1ps

module QDS_tb();

reg [5:0]p;
reg [2:0]d;
wire signed [2:0]q;


QDS QDS(
    .p(p),
    .d(d),
    .q(q)
);

initial begin
    p = 6'b111100;
    d = 3'b001;
end


endmodule