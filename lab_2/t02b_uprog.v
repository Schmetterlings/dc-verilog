// Perforemd by: {Full Last,First Name}
//
// Task 2. Implement two versions of a micro-programmable 
// finite state machine (FSM) working according to the given state diagram.
// Use only ROM and Register
// Create a testbench to verify the operation of both circuits. In the testbench
// assure going through all transitions. 
// Report in the console using $display task the state change.


`timescale 1ns/100ps

module UPROG_B(CLK, CLR, A, B, X, Y);
//Enumerate states
parameter S1 = 2'b01;
parameter S2 = 2'b11;
parameter S3 = 2'b00;
parameter S4 = 2'b10;
//Interface
input CLK, CLR;
input A, B;
output X, Y;
wire[1:0] nextQ;
wire sel;

ROM #(.A_W(3), .D_W(2))M1(.A({sel,nextQ}), .Q({X,Y}));
REG #(.W(2))R1(.CLK(CLK), .CLR(CLR), .D({X,Y}), .Q(nextQ));
//To build an input vector use the concatenation operator {} eg.: .I({A,B,A,B})
MUX4 MUX_1(.Y(sel), .SEL(nextQ), .I({A,B,B,A}));

initial begin
    //Initialize ROM memory using SET task
    M1.SET({1'b0,S1},{S2} );
    M1.SET({1'b1,S1},{S3} );
    M1.SET({1'b0,S2},{S4} );
    M1.SET({1'b1,S2},{S4} );
    M1.SET({1'b0,S3},{S2} );
    M1.SET({1'b1,S3},{S3} );
    M1.SET({1'b0,S4},{S3} );
    M1.SET({1'b1,S4},{S1} );
   

end

endmodule

module UPROG_B_TEST;
reg CLK, CLR, A, B;
wire X, Y;

//Unit Under Test
UPROG_B UUT(.CLK(CLK), .CLR(CLR), .A(A), .B(B), .X(X), .Y(Y));

//Main test vector generator
initial begin
     A=1'b0;
    B=1'b0;
    CLR=1'b0;
    #100;
    CLR=1'b1;
    #10;
    repeat(10) @(negedge CLK) #100 {A,B}={A,B}+1;
    CLR=1'b1;
    #10;
    CLR=1'b0;
    #100;
    {A,B}=2'b11;
    #100;
    repeat(10) @(negedge CLK)#100 {A,B}={A,B}-1;
    #10;
    $finish;
end

// Clock generator
initial begin
    CLK = 1'b0;
    forever #50 CLK = ~CLK;
end

initial begin
    $dumpfile("uprog_b.vcd");
    $dumpvars;
    $dumpon;    
    $monitor("%b %b:%b %b -> %b:%b%b", A,B,UUT.X,UUT.Y, UUT.nextQ, X, Y);
end

//State change reporter ...
reg [1:0] last_Q;

always @({UUT.X,UUT.Y}) begin
    $display("State change: %d -> %d", last_Q, {UUT.X,UUT.Y});
    last_Q = {UUT.X,UUT.Y};
end

always @(UUT.nextQ)
    $display("Next state is: %d for A,B  = %b", UUT.nextQ, {A,B});

endmodule

