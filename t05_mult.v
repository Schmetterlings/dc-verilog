// Perforemd by: {Full Last,First Name}
// Task 5: Implement using components from comp_lib.v a 2-bit combinational 
// multiplier MUL_2. Next, using module MUL_2 and full adders implement 
// a 4-bit combinational multiplier. Finally prepare a test bench and determine
//  maximal propagation time of designed 4x4 bit multiplier.

`timescale 1ns/100ps

module MUL_2(M, A, B);
output [3:0] M;
input [1:0] A, B;

//NOT
wire [2:0] N0_1;
NOT G_M0_1(.Y(N0_1[0]), .A(A[0])); //~A[0]
NOT G_M0_2(.Y(N0_1[1]), .A(B[0])); //~B[0]
NOT G_M0_3(.Y(N0_1[2]), .A(B[1])); //~B[1]


wire W0_1;

//M[0]...
NAND2 G_M0_4(.Y(W0_1), .A(A[0]), .B(B[0]));
NOT G_M0_5(.Y(M[0]), .A(M0_1));

//M[1]...
wire [3:0] W0_2;

NAND3 G_M0_6(.Y(W0_2[0]), .A(A[1]), .B(N0_1[0]), .C(B[1]));
NAND3 G_M0_7(.Y(W0_2[1]), .A(A[1]), .B(N0_1[0]), .C(B[0]));
NAND3 G_M0_8(.Y(W0_2[2]), .A(N0_1[2]), .B(B[0]), .C(A[1]));
NAND3 G_M0_9(.Y(W0_2[3]), .A(A[0]), .B(B[1]), .C(N0_1[1]));
NAND4 G_M0_A(.Y(M[1]), .A(W0_2[0]), .B(W0_2[1]), .C(W0_2[2]), .D(W0_2[3]));

//M[2]...
wire [1:0] W0_3;

NAND3 G_M0_B(.Y(W0_1[0]), .A(A[1]), .B(N0_1[0]), .C(B[1]));
NAND3 G_M0_C(.Y(W0_1[1]), .A(A[1]), .B(B[1]), .C(N0_1[1]));
NAND2 G_M0_D(.Y(M[2]), .A(W0_1[0]), .C(W0_1[1]));


//M[3]...
wire W0_4;

NAND4 G_M0_E(.Y(W0_4), .A(A[1]), .B(A[0]), .C(B[1]), .D(B[0]));
NOT G_M0_F(.Y(M[3]), .A(W0_4));

endmodule

module MUL_4(M, A, B);
output [7:0] M;
input [3:0] A, B;

MUL_2 M1(.M(), .A(A[1:0]), .B(B[1:0]));
//TODO: Complete implementation...

endmodule

module MUL_TEST;

output [7:0] M;
input [3:0] A, B;

MUL_4 M1(.M(), .A(), .B());

//Write stimulus and observer - log results to waveform and console
//Prove correctnes of the design
//Determine maximal propagation time of designed adder
initial begin
    //...
    #10;
    $finish;    
end

initial begin
    $dumpfile("mult.vcd");
    $dumpvars(0, MUL_TEST);
    $dumpon();
end

endmodule
