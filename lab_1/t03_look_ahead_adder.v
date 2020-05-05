// Task 3: Implement using components from comp_lib.v a 4-bit carry 
// look-ahead adder. Implement it with the idea of sharing gates. 
// Prove correctness of the design by applying appropriate test vectors.
// Using your test bench, determine the maximal propagation time of 
// the designed adder. At the end of the simulation print out this 
// result (e.g. using $display task).

`timescale 1ns/100ps
`include "comp_lib.v"

module XOR(Y,A,B);
output Y;
input A,B;
wire w1,w2,w3;//wires
NAND2 G1(.Y(w1), .A(A), .B(B));
NAND2 G2(.Y(w3), .A(A), .B(w1));
NAND2 G3(.Y(w2), .A(w1), .B(B));
NAND2 G4(.Y(Y), .A(w3), .B(w2));

endmodule

module OR(Y,A,B);
output Y;
input A,B;
wire nA,nB;
NOT g1(.Y(nA),.A(A));
NOT G2(.Y(nB),.A(B));
NAND2 G3(.Y(Y), .A(nA), .B(nB));

endmodule

//Carry generate and propagate module
module C_GP(nG, P, A, B);
output nG; // Carry not generate
output P;  // Carry propagate
input  A, B;
wire nG;
NAND2 G1(.Y(nG), .A(A), .B(B));
XOR G2(.Y(P),.A(A),.B(B));

endmodule

// 4-bit carry look-ahead adder module
module ADD_FAST(CO, S, A, B, CI);
output CO; 
output [3:0] S; 
input [3:0] A, B;
input CI;
wire g0,g1,g2,g3,p0,p1,p2,p3,c1,c2,c3,w1,w2,w3,w4;
C_GP GP0(.nG(ng0), .P(p0), .A(A[0]), .B(B[0]));
C_GP GP1(.nG(ng1), .P(p1), .A(A[1]), .B(B[1]));
C_GP GP2(.nG(ng2), .P(p2), .A(A[2]), .B(B[2]));
C_GP GP3(.nG(ng3), .P(p3), .A(A[3]), .B(B[3]));
NAND2 nG1(.Y(w1), .A(p0), .B(CI));
NAND2 nG2(.Y(c1), .A(ng0), .B(w1));
NAND2 nG3(.Y(w2), .A(p1), .B(c1));
NAND2 nG4(.Y(c2), .A(ng1), .B(w2));
NAND2 nG5(.Y(w3), .A(p2), .B(c2));
NAND2 nG6(.Y(CO), .A(ng3), .B(w1));
XOR G1(.Y(S[0]),.A(p0),.B(CI));
XOR G2(.Y(S[1]),.A(p1),.B(c1));
XOR G3(.Y(S[2]),.A(p2),.B(c2));
XOR G4(.Y(S[3]),.A(p3),.B(CO));

endmodule 

// 4-bit adder test bench
module ADD_4_TEST;
reg [3:0] A, B;
reg CI;
wire [3:0] Y;
wire CO;
time mpt;

ADD_FAST A1(.CO(CO), .S(Y), .A(A), .B(B), .CI(CI));

// Write stimulus and observer - log results to waveform and console
// Prove correctness of the design
// Determine maximal propagation time of designed adder
initial begin
    $display("\t\tCO a b c d <- A0 A1 A2 A3 + B0 B1 B2 B3");
    

    A = 4'b0;
    B = 4'b0;
    CI = 0;
    mpt = 0;
    
    repeat(15) begin
        #10 A = A + 1;
        #10;

        if (mpt == 0)
            mpt = $time;

        #10 B = B + 1;
        #10;
    end

    #10 $display("Maximal propagation time: %t", mpt);
    $finish;
end

initial begin
    $monitor("%t: %b %b <- %b + %b", $time, CO, Y, A, B);
    $dumpfile("add_4_fast.vcd");
    $dumpvars(0, ADD_4_TEST);
    $dumpon();
end

endmodule
