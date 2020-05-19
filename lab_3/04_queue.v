// Perforemd by: {Full Last,First Name}
//
// Task 4. Implement using the RAM16D memory module a ring register. 
// Implement notification lines for the empty and full queue. Protect 
// against writing to the full queue and reading from the empty queue. 
// Assure proper operation during simultaneous read and write.
// Prepare the test bench and prove the correctness of the queue 
// operation. Prove protection against reading the empty queue and 
// writing to the full queue. Prove correctness of simultaneous read 
// and write operation
//


`timescale 1ns/100ps

module QUEUE(CLK, INIT, WR, RD, DI, DQ, EMPTY, FULL);
input CLK, WR, RD, INIT;
input [7:0] DI;
output [7:0] DQ;
output EMPTY, FULL;

wire [3:0]stackQ,WRQ,RDQ;
wire w1,w2,we,nwr,nrd;
NOT np(nwr,WR);
NOT nt(nrd,RD);
NOR2 N1(w1,nwr,FULL);
NOR2 N2(w2,nrd,EMPTY);
NOR2 NE(we,w1,w2);
NOT n4(nwe,we);
NOR5 N3(EMPTY,stackQ[0],stackQ[1],stackQ[2],stackQ[3],FULL);

RAM16D #(.W(8))QUEU_MEM(.CLK(CLK), .WE(w1), .A(WRQ),.AR(RDQ), .DI(DI), .DQ(DQ));

CBUD #(.W(5))C_DATA_CNT(.CLK(CLK), .CLR(INIT), .CE(nwe), .UP(w1), .Q({FULL,stackQ}));
CB #(.W(4))C_RD_PTR(.CLK(CLK), .CLR(INIT), .CE(w2), .Q(RDQ));
CB #(.W(4))C_WR_PTR(.CLK(CLK), .CLR(INIT), .CE(w1), .Q(WRQ));

//...

endmodule

module QUEUE_TEST;
reg CLK, WR, RD,INIT;
reg [7:0] DI;
wire [7:0] DQ;
wire EMPTY, FULL;

 QUEUE Q1(CLK, INIT, WR, RD, DI, DQ, EMPTY, FULL);
//Main test vector generator
initial begin
    DI=8'b0;
 WR=0;
 RD=0;
 INIT=1'b1;
#10 INIT=1'b0;  
#10; 
    repeat(30) begin
    #5 WR = 1;

    #4 DI = DI +1; 
    #10 WR = 0;
    #10;
    end
     repeat(16) begin
    #5 WR = 1;
    RD=1;
    #4 DI = DI +1; 
    #10 WR = 0;
    RD=0;
    #10;
    end
    repeat(16) begin
    #5;
    RD=1;
    #4 DI = DI +1; 
    #10 ;
    RD=0;
    #10;
    end
 
 
    $finish;
end

// Clock generator
initial begin
    CLK = 1'b0;
    forever #5 CLK = ~CLK;
end

initial begin
    $dumpfile("queue.vcd");
    $dumpvars;
    $dumpon;
    //Complete monitor ststement here to show that your counter operates properly
    $monitor("DI %b , DQ %b, RD %b, WR %b, EMPTY %b, FULL %b",DI,DQ,RD,WR,EMPTY,FULL);
end

endmodule
