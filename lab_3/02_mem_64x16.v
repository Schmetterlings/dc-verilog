// Perforemd by: {Full Last,First Name}
//
// Task 2. Design a memory system that consists of 64 words by 16 bits memory 
// with bidirectional data port D using the RAM_16X4 module. Use simple components 
// (gates) available in the delivered library to connect multiple memory blocks.
// Prepare the test bench that checks designed memory capacity by writing unique 
// patterns to each cell. In the next cycle verify the memory content.
//

`timescale 1ns/100ps

module RAM_64x16(nCS, nWE, nOE, A, D);
input  nCS;
input nWE, nOE;
input [5:0] A;
inout [15:0] D;
wire [15:0] D_T;
wire [15:0] D_T2;

assign  D_T = nOE ? D : 16'bz;
assign  D = (~nOE&&nWE) ? D_T2 : 16'bz;

wire W_1, W_2; 
wire WS_1, WS_2, WS_3, WS_4;

NOT N1(.Y(W_1) ,.A(A[5]));
NOT N2(.Y(W_2), .A(A[4]));

NOR2 R1(.Y(WS_1), .A(A[5]), .B(A[4]));
NOR2 R2(.Y(WS_2), .A(W_1), .B(A[4]));
NOR2 R3(.Y(WS_3), .A(A[5]), .B(W_2));
NOR2 R4(.Y(WS_4), .A(W_1), .B(W_2));

RAM_16X4 M11(.nCS(WS_1), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[3:0]), .Q(D_T2[3:0]));
RAM_16X4 M12(.nCS(WS_1), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[7:4]), .Q(D_T2[7:4]));
RAM_16X4 M13(.nCS(WS_1), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[11:8]), .Q(D_T2[11:8]));
RAM_16X4 M14(.nCS(WS_1), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[15:12]), .Q(D_T2[15:12]));
RAM_16X4 M21(.nCS(WS_2), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[3:0]), .Q(D_T2[3:0]));
RAM_16X4 M22(.nCS(WS_2), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[7:4]), .Q(D_T2[7:4]));
RAM_16X4 M23(.nCS(WS_2), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[11:8]), .Q(D_T2[11:8]));
RAM_16X4 M24(.nCS(WS_2), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[15:12]), .Q(D_T2[15:12]));
RAM_16X4 M31(.nCS(WS_3), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[3:0]), .Q(D_T2[3:0]));
RAM_16X4 M32(.nCS(WS_3), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[7:4]), .Q(D_T2[7:4]));
RAM_16X4 M33(.nCS(WS_3), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[11:8]), .Q(D_T2[11:8]));
RAM_16X4 M34(.nCS(WS_3), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[15:12]), .Q(D_T2[15:12]));
RAM_16X4 M41(.nCS(WS_4), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[3:0]), .Q(D_T2[3:0]));
RAM_16X4 M42(.nCS(WS_4), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[7:4]), .Q(D_T2[7:4]));
RAM_16X4 M43(.nCS(WS_4), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[11:8]), .Q(D_T2[11:8]));
RAM_16X4 M44(.nCS(WS_4), .nWE(nWE), .nOE(nOE), .A(A[3:0]), .D(D_T[15:12]), .Q(D_T2[15:12]));

endmodule

module RAM_64x16_TEST;

reg nCS, nWE, nOE;
reg [5:0] AD;
wire [15:0] D;
reg [15:0] D_DRV;
reg [15:0] D_RD;

RAM_64x16 M1(.nCS(nCS), .nWE(nWE), .nOE(nOE), .A(AD), .D(D));

//For writing the data use D_DRV - remember about conflicts
assign D = D_DRV;

initial begin
    nCS = 1'b1; nWE = 1'b1; nOE = 1'b1;
    D_DRV = 16'hzzzz;
    MEM_WR(6'd10,16'd3141);
    MEM_WR(6'd11,16'd3142);
    MEM_WR(6'd12,16'd3143);
    MEM_RD(6'd11,D_RD);
    MEM_RD(6'd10,D_RD);
    MEM_RD(6'd12,D_RD);
    


    #100;
    $finish;
end
initial begin
    $dumpfile("membig_test.vcd");
    $dumpvars;
    $dumpon;
end

task MEM_RD;
input [5:0] A;
output [15:0] D1;
begin
    $display("Reading data...");
    D_DRV=16'bz;
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
input [5:0] A;
input [15:0] D;
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