// Performed by: Marut Kamil
//
// Write a model of a 4 bit up-down (reversible) binary counter.  
// Implement the counter in the form of a micro-programmable circuit 
// using components from the delivered library. Create a test bench to 
// verify circuit (operation) operation. Prove wrapping around of counter 
// in both direction and counting direction change

`timescale 1ns/100ps

//CBUD - Counter Binary Up Down
module CBUD(CLK, CLR, DIR, Q);
input CLK; //Clock input
input CLR; //Clear input - when asserted place counter in state 3'b000
input DIR; //Counting direction input 
output [2:0] Q; //Output and internal state of the machine

wire [2:0] A;

ROM #(.A_W(4), .D_W(3))M1(.A({A, DIR}), .Q(Q));
REG #(.W(3))R1(.CLK(CLK), .CLR(CLR), .D(Q), .Q(A));

initial begin
    //Initialize ROM memory using SET task
    M1.SET(4'b0000, 3'b001);
    M1.SET(4'b0001, 3'b111);
    M1.SET(4'b0010, 3'b010);
    M1.SET(4'b0011, 3'b000);
    M1.SET(4'b0100, 3'b011);
    M1.SET(4'b0101, 3'b001);
    M1.SET(4'b0110, 3'b100);
    M1.SET(4'b0111, 3'b010);
    M1.SET(4'b1000, 3'b101);
    M1.SET(4'b1001, 3'b011);
    M1.SET(4'b1010, 3'b110);
    M1.SET(4'b1011, 3'b100);
    M1.SET(4'b1100, 3'b111);
    M1.SET(4'b1101, 3'b101);
    M1.SET(4'b1110, 3'b000);
    M1.SET(4'b1111, 3'b110);
end

endmodule


module CBUD_TEST;

reg CLK; //Clock signal
reg CLR; //Clear input - when asserted place counter in state 3'b000
reg DIR; //Counting direction input 
wire [2:0] Q; //Output and internal state of the machine    
    
// Unit Under Test    
CBUD UUT(.CLK(CLK), .CLR(CLR), .DIR(DIR), .Q(Q));

// Main test vector generator
initial begin
    DIR = 1'b0;
    CLR = 1'b1;
    repeat(10) @(negedge CLK); 
    CLR = 1'b0;
    repeat(10) @(negedge CLK);

    // Change direction
    DIR = 1'b1;
    repeat(10) @(negedge CLK);

    $finish;
end

// Clock generator
initial begin
    CLK = 1'b0;
    forever #50 CLK = ~CLK;
end

initial begin
    $dumpfile("cbud.vcd");
    $dumpvars;
    $dumpon;
    $monitor("%b:%b --> %b", UUT.A, DIR, Q); // Cur:Dir --> Next
end

always @(DIR) begin
    $display("Direction change.");
end

endmodule

