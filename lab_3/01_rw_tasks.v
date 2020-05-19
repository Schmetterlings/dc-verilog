// Performed by: Marut Kamil
//
// Task 1. Build from RAM_16X4 a memory module equipped with bidirectional 
// data port D. Write a testbench that verifies the operation of reading 
// and writing data to the memory component RAM_16X4 available in mem_lib.v. 
// Prepare the following tasks: 
// task MEM_WR(input A, input D); 
// task MEM_RD(input A, output D); 
// That are responsible for writing and reading data. Remember for assuring 
// the correct driving of bus lines to avoid conflicts and assure the proper 
// sequence of signals. In the testbench write a test of memory operation 
// using prepared tasks

`timescale 1ns/100ps

module RAM_16SP(nCS, nWE, nOE, A, D);
input nCS, nWE, nOE;
input [3:0] A;
inout [3:0] D;

wire [3:0] D_T;

RAM_16X4 M1(.nCS(nCS), .nWE(nWE), .nOE(nOE), .A(A), .D(D), .Q(D_T));

// The correct memory is loaded into D_T
// but for some reason the continuous assignment
// does not assign the D_T to D
assign #10 D = (~nOE && nWE) ? D_T : 4'bz;

always @(A or D or D_T) begin
    $display("%m: D -> %b, D_T -> %b", D, D_T);
end

endmodule

module MEM_TEST;

reg nCS, nOE, nWE;
reg [3:0] ADR;
wire [3:0] MEM;

reg [3:0] D_DRV;
reg [3:0] D_RD;

RAM_16SP M1(.nCS(nCS), .nWE(nWE), .nOE(nOE), .A(ADR), .D(MEM));

//For writing the data use D_DRV - remember about conflicts
assign MEM = D_DRV;

initial begin
    #20; 
    nCS = 1'b1; nWE = 1'b1; nOE = 1'b1;
    ADR = 4'h0; D_DRV = 4'hx; D_RD = 4'hx;

    // Writing memory
    #10;
    nCS = 1'b0;
    #10;
    nWE = 1'b0;
    #10;
    MEM_WR(4'b0101, 4'b1110);
    #10;
    MEM_WR(4'b1010, 4'b0001);
    #10;
    nWE = 1'b1;

    // Reading memory
    #10;
    nOE = 1'b0;
    #10;
    MEM_RD(4'b0101, D_RD);
    #10;
    MEM_RD(4'b1010, D_RD);
    #10;
    nOE = 1'b1;
    #10;
    nCS = 1'b1;
    $display("Simulation finished.");
    $finish;
end

initial begin
    //$monitor("%t -> Chip select: %b, Write: %b, Output: %b - WR: %b, RD: %b", $time, nCS, nWE, nOE, D_DRV, D_RD);
    $monitor("%t -> WR: %b, RD: %b", $time, D_DRV, D_RD);
    $dumpfile("mem_test.vcd");
    $dumpvars;
    $dumpon;
end

task MEM_RD;
input [3:0] A;
output [3:0] D;
begin
    $display("%m: Reading memory...");
    #5 ADR = A;
    #5 D = MEM;
end
endtask

task MEM_WR;
input [3:0] A;
input [3:0] D;
begin
    $display("%m: Writing memory...");
    #5 ADR = A;
    D_DRV = D;
end
endtask

endmodule

