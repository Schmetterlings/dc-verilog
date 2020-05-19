// Perforemd by: {Full Last,First Name}
//
// Task 3. Implement using the RAM16 synchronous memory module 
// a 16 level stack consisting of 8-bit words. Protect it against 
// stack overflow. Implement outputs notifying about the empty and 
// the full stack.
// Prepare the test bench and prove the correctness of the operation 
// of the designed stack. In the testbench check 

`timescale 1ns/100ps

module STACK(CLK, INIT, PUSH, POP, DI, DQ, EMPTY, FULL);
input CLK, INIT, PUSH, POP;
input [7:0] DI;
output [7:0] DQ;
output EMPTY, FULL;
wire [3:0]stackQ;
wire w1,w2,we,npush;
NOT np(npush,PUSH);
NOR2 N1(w1,npush,FULL);
NOR2 NE(we,w1,POP);
NOT n4(nwe,we);
NOR5 N3(EMPTY,stackQ[0],stackQ[1],stackQ[2],stackQ[3],FULL);
RAM16S #(.W(8))STACK_MEM(.CLK(CLK), .WE(w1), .A(stackQ), .DI(DI), .DQ(DQ));
CBUD #(.W(5))SP_CNT(.CLK(CLK), .CLR(INIT), .CE(nwe), .UP(w1), .Q({FULL,stackQ}));

endmodule

module STACK_TEST;
reg CLK, INIT, PUSH, POP;
reg [7:0] DI;
wire [7:0] DQ;
wire EMPTY, FULL;

STACK ST1(
    .CLK(CLK), 
    .INIT(INIT),
    .PUSH(PUSH), 
    .POP(POP), 
    .DI(DI), 
    .DQ(DQ), 
    .EMPTY(EMPTY), 
    .FULL(FULL));

//Main test vector generator
initial begin
 DI=8'b0;
 POP=0;
#0 INIT=1'b1;
#10 INIT=1'b0;

    //Write your test here...    
    repeat(30) begin
    #5 PUSH = 1;
    #4 DI = DI +1; 
    #10 PUSH = 0;
    #10;
    end
    repeat(16)begin
    #10 POP=1;
    end
    #10
    POP=0;
     #10
       repeat(5) begin
    #5 PUSH = 1;
    #4 DI = DI +1; 
    #10 PUSH = 0;
    #10;
    end
    #10
    POP=1;
    #20;
    POP=0;
    #20;
    $finish;
end

// Clock generator
initial begin
    CLK = 1'b0;
    forever #5 CLK = ~CLK;
end

initial begin
    $dumpfile("stack.vcd");
    $dumpvars;
    $dumpon;
    //Complete monitor ststement here to show that your counter operates properly
    $monitor("DI %b , DQ %b, PUSH %b, POP %b, EMPTY %b, FULL %b",DI,DQ,PUSH,POP,EMPTY,FULL);
end

endmodule
