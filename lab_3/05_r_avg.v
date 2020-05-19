// Perforemd by: Przemysław Jaskuła
//
// Task 5. Implement using RAM16 a module for calculating the running 
// average of 16 input samples. The unit should complete calculation 
// during a single clock cycle using the formula: 
//        y = y + a[i] - a[i-16]: i= 16…n.
// Prepare the test bench and prove the correctness of your implementation. 
// Deliver a stream of data and check computations correctness.


`timescale 1ns/100ps

module R_AVG(CLK, INIT, WE, DI, DQ);
input CLK;
input INIT;
input WE;  //Sample write enable line
input [7:0] DI; //Input sample
output [11:0] DQ;

wire wa2,wa1;
wire [3:0] ckw,dqd;
// 16-tap delay
RAM16S #(.W(8))M1(.CLK(CLK), .WE(WE), .A(ckw[3:0]), .DI(DI), .DQ(dqd));
CB #(.W(4))C1(.CLK(CLK), .CLR(INIT), .CE(WE), .Q(ckw));

//d[i] = a[i] - a[i-16]
NOT n1(ndqd,dqd);
ADD #(.W(9))A1(.CO(), .S(wa1), .A(DI), .B(ndqd), .CI(1'b1));
//y[i] = y[i-1] + d[i]
ADD #(.W(12))A2(.CO(), .S(wa2), .A(DQ), .B(wa1), .CI(1'b0));

//y[i-1] <- y[i]
FDCE #(.W(12)) FF1(
    .CLK(CLK), 
    .CLR(INIT), 
    .CE(WE), 
    .D(wa2), 
    .Q(DQ));

endmodule

module R_AVG_TEST;
reg CLK, WE, INIT;
reg [7:0] D;
wire [11:0] AV_D;

R_AVG R1(
    .CLK(CLK), 
    .INIT(INIT), 
    .WE(WE), 
    .DI(D), 
    .DQ(AV_D));
//Main test vector generator
initial begin
    D = 8'd0;
    INIT = 1'b1;
    repeat(3) @(negedge CLK);
    INIT = 1'b0;
    
    repeat(20) begin
        @(negedge WE);
        D = D + 1;
    end
    //Write your test here...    
    repeat(100) @(negedge CLK);
    $finish;
end

//Write sample generator
always begin
    WE = 1'b0;
    repeat(3) @(negedge CLK);
    WE = 1'b1;
    @(negedge CLK) D={$random} %8;
end

// Clock generator
initial begin
    CLK = 1'b0;
    forever #5 CLK = ~CLK;
end

initial begin
    $dumpfile("r_avg.vcd");
    $dumpvars;
    $dumpon;
    //Complete monitor ststement here to show that your counter operates properly
    $monitor("D %b , AvD %b, ",D, AV_D);
end

endmodule
