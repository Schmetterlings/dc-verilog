// Perforemd by: {Full Last,First Name}
//
// Task 2. Design an overflow detector by copping your frequency meter to prepared t2.v file. 
// Here you will find module declaration including OVF (Overflow output). The overflow signal 
// should be treated lie other measurement results and should be passed through the latch register
// to retain the result value for displaying it for user.
//

`timescale 1ns/100ps

module FM_OVF(CLK, CLR, F_IN, QH, QD, QU, OVF, nDONE);
input CLK;  // Reference clock
input CLR; // Frequency meter clear signal
input F_IN; // Measured frequency 
output [3:0] QH, QD, QU; // Measurement result
output OVF; // Result overflow notification
output nDONE; // Notification about completing measurement process

// Control unit
wire [3:0] Q_CTRL;
wire [7:0] nCTRL;
wire [1:0] DUMMY;
wire GATE_EN; // Gate
wire G_F_IN; // Gated F_IN
wire CNT_CLR; // Counter clear
wire LD; // Load latch

initial begin
    $monitor("QH: %b, QD: %b, QU: %b", QH, QD, QU);
end

// Counters and latches
wire [3:0] QC_H, QC_D, QC_U;

// Input signal gate
nand #3(G_F_IN, GATE_EN, F_IN);
// Gate control
SN7493 CTRL_CNT1(.CLK(CLK), .R0(CLR), .Q(Q_CTRL));
SN7442 CTRL_DEC1(.Y({DUMMY, nCTRL}), .I({1'b0, Q_CTRL[3:1]}));
SN7474 CTRL_G_CTRL(.CLK(1'b0), .nS(nCTRL[0]), .nR(nCTRL[5]), .Q(GATE_EN), .nQ());
// Generate LD and CNT_CLR note required signals polarity
SN7474 CTRL_G_LD(.CLK(1'b0), .nS(nCTRL[6]), .nR(nCTRL[7]), .Q(LD), .nQ());
SN7474 CTRL_G_CNT(.CLK(1'b0), .nS(nCTRL[7]), .nR(nCTRL[0]), .Q(CNT_CLR), .nQ());

assign nDONE = nCTRL[7]; // End of measurement notification

// Counter - asynchronous BCD
SN7490 C1(.CLK(G_F_IN), .R0(CNT_CLR), .R9(1'b0), .Q(QC_U));
SN7490 C2(.CLK(QC_U[3]), .R0(CNT_CLR), .R9(1'b0), .Q(QC_D));
SN7490 C3(.CLK(QC_D[3]), .R0(CNT_CLR), .R9(1'b0), .Q(QC_H));
// Latch - quad D flip-flop triggered on falling edge
SN7474_4 L1(.CLK(LD), .nCLR(1'b1), .D(QC_U), .Q(QU));
SN7474_4 L2(.CLK(LD), .nCLR(1'b1), .D(QC_D), .Q(QD));
SN7474_4 L3(.CLK(LD), .nCLR(1'b1), .D(QC_H), .Q(QH));

wire nCNT_CLR;
not #2(nCNT_CLR, CNT_CLR);
SN7472 OVF_DETECT(.CLK(QC_H[3]), .nR(nCNT_CLR), .nS(1'b1), .J(1'b1), .K(1'b0), .Q(OVF), .nQ());

endmodule


module T2_TEST;
reg CLK;  //Reference clock
reg CLR;
wire F_IN; //Measured frequency 
output [3:0] QH, QD, QU; //Measurement result
wire OVF;
wire nDONE;
reg [31:0] F_SET;

FM_OVF UUT(
    .CLK(CLK), .CLR(CLR), 
    .F_IN(F_IN), 
    .QH(QH), .QD(QD), .QU(QU), .OVF(OVF) ,
    .nDONE(nDONE));

FREQ_GEN FG(.CLK(F_IN), .F(F_SET));

initial begin
    F_SET = 32'd145;
    CLR = 1'b1;
    repeat(2) @(posedge CLK);
    CLR = 1'b0;
    repeat(3) @(negedge nDONE);
    F_SET = 32'd1045;
    repeat(2) @(negedge nDONE);    
    repeat(3) @(posedge CLK);
    $finish;
end

always @(negedge nDONE)
    $display("Measured frequency : %b : %d%d%d ", OVF, QH, QD, QU);

initial begin
    CLK = 1'b0;
    forever begin
        #50_000 CLK = ~CLK;
    end
end

initial begin
    $dumpfile("t2.vcd");
    $dumpvars;
    $dumpon;
end

endmodule
