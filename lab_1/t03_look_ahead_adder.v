// Performed by: Marut Kamil
// Task 3: Implement using components from comp_lib.v a 4-bit carry 
// look-ahead adder. Implement it with the idea of sharing gates. 
// Prove correctness of the design by applying appropriate test vectors.
// Using your test bench, determine the maximal propagation time of 
// the designed adder. At the end of the simulation print out this 
// result (e.g. using $display task).

`timescale 1ns/100ps
`include "comp_lib.v"

module OR2(Y, A, B);
output Y;
input A, B;

NAND2 N1(.Y(Y), .A(~A), .B(~B));
endmodule

module OR3(Y, A, B, C);
output Y;
input A, B, C;

NAND3 N1(.Y(Y), .A(~A), .B(~B), .C(~C));
endmodule

module OR4(Y, A, B, C, D);
output Y;
input A, B, C, D;

NAND4 N1(.Y(Y), .A(~A), .B(~B), .C(~C), .D(~D));
endmodule

module OR5(Y, A, B, C, D, E);
output Y;
input A, B, C, D, E;

NAND5 N1(.Y(Y), .A(~A), .B(~B), .C(~C), .D(~D), .E(~E));
endmodule

module XOR2(Y, A, B);
output Y;
input A, B;
wire LHS, RHS;

NAND2 G2(.Y(LHS), .A(A), .B(~B));
NAND2 G3(.Y(RHS), .A(~A), .B(B));
NAND2 G4(.Y(Y), .A(LHS), .B(RHS));
endmodule

// Carry generate and propagate module
module C_GP(G, P, A, B);
output G;  // Carry generate
output P;  // Carry propagate
input  A, B;
wire nG;

assign G = A & B;
assign P = A ^ B;
endmodule

// 4-bit carry look-ahead adder module
module ADD_FAST(CO, S, A, B, CI);
output CO;
output [3:0] S;
input [3:0] A, B;
input CI;

wire p0, p1, p2, p3, g0, g1, g2, g3, c0, c1, c2, c3;

C_GP GP0(.G(g0), .P(p0), .A(A[0]), .B(B[0]));
C_GP GP1(.G(g1), .P(p1), .A(A[1]), .B(B[1]));
C_GP GP2(.G(g2), .P(p2), .A(A[2]), .B(B[2]));
C_GP GP3(.G(g3), .P(p3), .A(A[3]), .B(B[3]));

assign c0 = CI,
       c1 = g0 | (p0 & CI),
       c2 = g1 | (p1 & g0) | (p1 & p0 & CI),
       c3 = g2 | (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & CI),
       CO = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & CI);

assign S[0] = p0 ^ c0,
       S[1] = p1 ^ c1,
       S[2] = p2 ^ c2,
       S[3] = p3 ^ c3;
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
    $monitor("%t: %b %b <- %b + %b", $time, CO, Y, A, B);

    A = 4'b0;
    B = 4'b0;
    CI = 0;
    mpt = 0;
    
    repeat(15) begin
        #10 A = A + 1;

        if (mpt == 0)
            mpt = $time;

        #10 B = B + 1;
    end

    #10 $display("Maximal propagation time: %t", mpt);
    $finish;
end

initial begin
    $dumpfile("add_4_fast.vcd");
    $dumpvars(0, ADD_4_TEST);
    $dumpon();
end

endmodule
