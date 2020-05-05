// Perforemd by: {Full Last,First Name}
// Task 4: Implement a 1-digit BCD adder using delivered components 
// library and already designed components. Create a 3-digit BCD adder 
// and verify its operation by preparing respective excitation vectors. 
// Using your test bench, determine the maximal propagation time of 
// the designed adder. At the end of the simulation print out this 
// result (e.g. using $display task).
`timescale 1ns/100ps

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

module ADD_BCD(CO, S, A, B, CI);
output CO; 
output [3:0] S; 
input [3:0] A, B;
input CI;
wire [3:0] w1;
wire [3:0] w3;
wire w2,nY,s1,s2;

ADD_4 A4_1(.CO(w2), .S(w1), .A(A), .B(B), .CI(CI));
NOT n1(.Y(nY),.A(w2));
NAND2 G1(.Y(s1), .A(w1[3]), .B(w1[2]));
NAND2 G2(.Y(s2), .A(w1[3]), .B(w1[1]));
NAND3 G3(.Y(CO), .A(s1), .B(s2),.C(nY));
assign #(0) w3[0] = 1'b0;
assign #(0) w3[1] = CO;
assign #(0) w3[2] = CO;
assign #(0) w3[3] = 1'b0;
ADD_4 A4_2(.CO(), .S(S), .A(w3), .B(w1), .CI(1'b0));


endmodule 

module ADD_BCD_TEST;
reg [11:0] A, B;
reg CI;
wire [11:0] Y;
wire CO,w1,w2;

ADD_BCD AD_1(.CO(w1), .S(Y[3:0]), .A(A[3:0]), .B(B[3:0]), .CI(CI));
ADD_BCD AD_2(.CO(w2), .S(Y[7:4]), .A(A[7:4]), .B(B[7:4]), .CI(w1));
ADD_BCD AD_3(.CO(CO), .S(Y[11:8]), .A(A[11:8]), .B(B[11:8]), .CI(w2));

//Write stimulus and observer - log results to waveform and console
//Prove correctnes of the design
//Determine maximal propagation time of designed adder
initial begin
    CI=1'b0;
    A=12'b0;
    B=12'b0;
    repeat(9)#15 {A[3:0]}={A[3:0]}+1;
     repeat(9)#15 {B[3:0]}={B[3:0]}+1;
     #10 A[3:0]=4'b0;
     #10 B[3:0]=4'b0;
  repeat(9)#15 {A[7:4]}={A[7:4]}+1;
     repeat(9)#15 {B[7:4]}={B[7:4]}+1;
     #10 A[7:4]=4'b0;
     #10 B[7:4]=4'b0;
      repeat(9)#15 {A[11:8]}={A[11:8]}+1;
     repeat(9)#15 {B[11:8]}={B[11:8]}+1;
     #10 A[11:8]=4'b0;
     #10 B[11:8]=4'b0;
    #10;
    $finish;    
end

initial begin
    $monitor("%t: %b + %b  == %b  co: %b", $time, A, B,Y,CO );
    $dumpfile("add_bcd.vcd");
    $dumpvars(0, ADD_BCD_TEST);
    $dumpon();
end

endmodule
