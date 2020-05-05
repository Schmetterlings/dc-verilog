// Perforemd by: {Full Last,First Name}
// Task 1: Implement using components from comp_lib.v a 4-bit ripple 
// carry adder. Implement it with the idea of using half adder modules 
// than using half adders, implement a single bit full adder. Finally, 
// assemble a 4-bit adder. Try to use a minimal number of components. 
// Take care of implementing the XOR gate. Think about resource sharing 
// (e.g.NAND gates). Write a stimulus to observe the 4-bit adder operation. 
// Log results to waveform and console. Prove correctness of the design 
// by applying appropriate test vectors. Using your test bench, determine 
// the maximal propagation time of the designed adder. Design an observer 
// block that automatically records maximal response delay during 
// the simulation process. At the end of the simulation print out this 
// result (e.g. using $display task).

`timescale 1ns/100ps

// Half adder module
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

// 4-bit adder module
module ADD_4(CO, S, A, B, CI);
output CO; 
output [3:0] S; 
input [3:0] A, B;
input CI;

wire w1,w2,w3;
FA A1(.CO(w1), .S(S[0]), .A(A[0]), .B(B[0]), .CI(CI));
FA A2(.CO(w2), .S(S[1]), .A(A[1]), .B(B[1]), .CI(w1));
FA A3(.CO(w3), .S(S[2]), .A(A[2]), .B(B[2]), .CI(w2));
FA A4(.CO(CO), .S(S[3]), .A(A[3]), .B(B[3]), .CI(w3));

endmodule 

// 4-bit adder test bench
module ADD_4_TEST;
reg [3:0] A, B;
reg CI;
wire [3:0] Y;
wire CO;

//Time variables for observer
time tp,tp_max;

ADD_4 A4_1(.CO(CO), .S(Y), .A(A), .B(B), .CI(CI));

//Write stimulus and observer - log results to waveform and console
//Prove correctnes of the design
//Determine maximal propagation time of designed adder
initial begin
    A=4'b1111;
    B=4'b0000;
    CI=0;
    #100;
    repeat(16)#100 {A,B}={A,B}+1;
        
     $display("tp_max  = %t", tp_max);
    $finish;    
end

initial begin
    $monitor("%t: %b + %b  == %b  co: %b", $time, A, B,Y,CO );
    $dumpfile("add_4_test.vcd");
    $dumpvars(0, ADD_4_TEST);
    $dumpon();
end
initial begin
    tp=0;
    tp_max=0;
end
always @(Y[3]) begin
    tp_max=$time;
end
always @(Y) begin
    tp=$time-tp;
end

endmodule
