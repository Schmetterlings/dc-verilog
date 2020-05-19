// Perforemd by: {Full Last,First Name}
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
//

`timescale 1ns/100ps

module RAM_16SP(nCS, nWE, nOE, A, D);
input nCS, nWE, nOE;
input [3:0] A;
inout [3:0] D;
wire [3:0] D_T;
wire [3:0] D_T2;
RAM_16X4 M1(.nCS(nCS), .nWE(nWE), .nOE(nOE), .A(A), .D(D_T), .Q(D_T2));
assign  D_T = nOE ? D : 4'bz;
assign  D = (~nOE&&nWE) ? D_T2 : 4'bz;


always @(A or D or D_T) begin
    $display("%m: D -> %b, D_T -> %b , D_T2 -> %b", D, D_T,D_T2);
end

endmodule

module MEM_TEST;

reg nCS, nOE, nWE;
reg [3:0] AD;
wire [3:0] D;

reg [3:0] D_DRV;
reg [3:0] D_RD;

RAM_16SP M1(.nCS(nCS), .nWE(nWE), .nOE(nOE), .A(AD), .D(D));

//For writing the data use D_DRV - remember about conflicts
assign D = D_DRV;

initial begin
    D_DRV = 4'hz;
    AD=4'b0;
    nCS=1;
    nOE=1;
    nWE=1;
    $display("My testbench...");
    //...?
    MEM_WR(4'b0100, 4'b1100);
    MEM_WR(4'b0101, 4'b1110);
    MEM_RD(4'b0100,D_RD);
    MEM_RD(4'b0101,D_RD);
    #100;
    $display("Finish...");
    $finish;
end

initial begin
    $dumpfile("mem_test.vcd");
    $dumpvars;
    $dumpon;
end

task MEM_RD;
input [3:0] A;
output [3:0] D1;
begin
    $display("Reading data...");
    D_DRV=4'bz;
    #10 ;
    nCS=0;
    AD=A;
     nOE = 1'b0;
    #15;
    D1=D;
    nOE = 1'b1;
    #10;
    nCS=1;
    
    end
endtask

task MEM_WR;
input [3:0] A;
input [3:0] D;
begin
    $display("Writing data...");
    #10;
     nCS = 1'b0;
     #10;
     AD=A;
    D_DRV = D;
    nOE = 1'b1;
    #10
    nWE=1'b0;
    #20;
    nWE=1;
    #5
    nCS = 1'b1;    
end
endtask

endmodule

