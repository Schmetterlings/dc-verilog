// Perforemd by: {Full Last,First Name}
// Task 4: Implement a 1-digit BCD adder using delivered components 
// library and already designed components. Create a 3-digit BCD adder 
// and verify its operation by preparing respective excitation vectors. 
// Using your test bench, determine the maximal propagation time of 
// the designed adder. At the end of the simulation print out this 
// result (e.g. using $display task).
`timescale 1ns/100ps

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
assign #(0) w3 = 4'b0000;
assign #(0) w3[2:1] = CO;
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
    //...
    #10;
    $finish;    
end

initial begin
    $dumpfile("add_bcd.vcd");
    $dumpvars(0, ADD_BCD_TEST);
    $dumpon();
end

endmodule
