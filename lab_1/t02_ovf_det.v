// Task 2: Implement using components from comp_lib.v an overflow detector
// output for 4-bit binary adder used for two's complement arithmetic. 
// Implement a unit that can add and subtract two's complement numbers, 
// using an adder with an overflow detector. Verify your implementation 
// with the respective test bench. Check correctness of operation of 
// the designed unit applying respective test vectors. Write stimulus 
// and responses to console and VCD file for waveform displaying.

`timescale 1ns/100ps
module XOR(Y,A,B);
output Y;
input A,B;
wire w1,w2,w3;//wires
NAND2 G1(.Y(w1), .A(A), .B(B));
NAND2 G2(.Y(w3), .A(A), .B(w1));
NAND2 G3(.Y(w2), .A(w1), .B(B));
NAND2 G4(.Y(Y), .A(w3), .B(w2));

endmodule
module HA(nC, S, A, B);
output S; //Sum
output nC; //not Carry
input A, B;
wire w1,w2;//wires
NAND2 G1(.Y(nC), .A(A), .B(B));
NAND2 G2(.Y(w1), .A(A), .B(nC));
NAND2 G3(.Y(w2), .A(nC), .B(B));
NAND2 G4(.Y(S), .A(w1), .B(w2));

endmodule

// 1-bit full adder module
module FA(CO, S, A, B, CI);
output CO; 
output S; 
input A, B, CI;
wire w1,w2,w3;

HA H1(.nC(w1), .S(w3), .A(A), .B(B));
HA H2(.nC(w2), .S(S), .A(w3), .B(CI));
NAND2 G1(.Y(CO), .A(w1), .B(w2));


endmodule

module ADD_4_OVF(OVF, CO, S, A, B, CI);
output OVF; //Oveflow output
output CO; 
output [3:0] S; 
input [3:0] A, B;
input CI;
wire w1,w2,w3,w4,w5;
//1-bit full adder...?
FA A1(.CO(w1), .S(S[0]), .A(A[0]), .B(B[0]), .CI(CI));
FA A2(.CO(w2), .S(S[1]), .A(A[1]), .B(B[1]), .CI(w1));
FA A3(.CO(w3), .S(S[2]), .A(A[2]), .B(B[2]), .CI(w2));
FA A4(.CO(CO), .S(S[3]), .A(A[3]), .B(B[3]), .CI(w3));
NAND2 G1(.Y(nC), .A(CO), .B(w3));
NAND2 G2(.Y(w4), .A(CO), .B(nC));
NAND2 G3(.Y(w5), .A(nC), .B(w3));
NAND2 G4(.Y(OVF), .A(w4), .B(w5));

endmodule 

module controlunit(nB,B,ctrl);
output[3:0] nB;
input [3:0] B;
input ctrl;

XOR G1(.Y(nB[0]),.A(B[0]),.B(ctrl));
XOR G2(.Y(nB[1]),.A(B[1]),.B(ctrl));
XOR G3(.Y(nB[2]),.A(B[2]),.B(ctrl));
XOR G4(.Y(nB[3]),.A(B[3]),.B(ctrl));

endmodule


module ADD_4_OVF_TEST;
reg [3:0] A, B;
reg CI;
wire [3:0] Y,nB;
wire CO;
wire OVF;
controlunit c1(.nB(nB),.B(B),.ctrl(CI));
ADD_4_OVF A4_1(.OVF(OVF), .CO(CO), .S(Y), .A(A), .B(nB), .CI(CI));

//Write stimulus and observer - log results to waveform and console
//Prove correctnes of the design
//Determine maximal propagation time of designed adder
initial begin
    A = 4'b0;
    B = 4'b0;
    CI = 0;
    repeat(15) begin
        #10 A = A + 1;
        #10;
        #10 B = B + 1;
        #10;
    end
    CI=1'b1;
    repeat(15) begin
        #10 A = A + 1;
        #10;
        #10 B = B + 1;
        #10;
    end

    #10;
    $finish;    
end

initial begin
    $monitor("%t: %b %b %b <- %b +- %b", $time,OVF ,CO, Y, A, B);
    $dumpfile("add_4_ovf.vcd");
    $dumpvars(0, ADD_4_OVF_TEST);
    $dumpon();
end

endmodule

