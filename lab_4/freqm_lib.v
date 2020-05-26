`timescale 1ns/100ps

//Asynchronous BCD counter
//Asynchronous zero - R0 -> Q = 4'd0
//Asynchronous nine - R9 -> Q = 4'd9
module SN7490(CLK, R0, R9, Q);
input CLK;
input R9, R0;
output [3:0] Q;

wire [3:0] nQ;
wire nR09;
wire nR0, nR9;
wire J3;

not #2 G1(nR0, R0);
not #2 G2(nR9, R9);
nor #2 G3(nR09, R0, R9);
nor #2 G4(J3, nQ[1], nQ[2]);
SN7472 FF0(.CLK(CLK), .nR(nR0), .nS(nR9), .J(1'b1), .K(1'b1), .Q(Q[0]), .nQ(nQ[0]));
SN7472 FF1(.CLK(Q[0]), .nR(nR09), .nS(1'b1), .J(nQ[3]), .K(1'b1), .Q(Q[1]), .nQ(nQ[1]));
SN7472 FF2(.CLK(Q[1]), .nR(nR09), .nS(1'b1), .J(1'b1), .K(1'b1), .Q(Q[2]), .nQ(nQ[2]));
SN7472 FF3(.CLK(Q[0]), .nR(nR0), .nS(nR9), .J(J3), .K(Q[3]), .Q(Q[3]), .nQ(nQ[3]));

endmodule

//Asynchronous binary counter
//Asynchronous zero - R0 -> Q = 4'd0
module SN7493(CLK, R0, Q);
input CLK;
input R0;
output [3:0] Q;
wire nR0;

not #2 G1(nR0, R0);
SN7472 FF0(.CLK(CLK),  .nR(nR0), .nS(1'b1), .J(1'b1), .K(1'b1), .Q(Q[0]), .nQ());
SN7472 FF1(.CLK(Q[0]), .nR(nR0), .nS(1'b1), .J(1'b1), .K(1'b1), .Q(Q[1]), .nQ());
SN7472 FF2(.CLK(Q[1]), .nR(nR0), .nS(1'b1), .J(1'b1), .K(1'b1), .Q(Q[2]), .nQ());
SN7472 FF3(.CLK(Q[2]), .nR(nR0), .nS(1'b1), .J(1'b1), .K(1'b1), .Q(Q[3]), .nQ());

endmodule

// Binary up counter with 
// count enable Q <- EN ? Q + 1 : Q
// parallel synchronous load  Q <- LD ? D : Q
// and asynchronous clear Q <- nCLR ? Q : 4'b0000
module SN74161(CLK, nCLR, LD, EN, D, Q, ENO);
input CLK, nCLR, LD, EN;
input [3:0] D;
output [3:0] Q;
output ENO;

wire nLD;

not #2 (nLD, LD);
not #2 (nEN, EN);

C_LD C_LD0(.EA(DJ_0), .nEA(DK_0), .E(LD), .A(D[0]));
nand #2(CN_0, nLD, nEN);
SN7472A FF0(.CLK(CLK), .nR(nCLR), .nS(1'b1), .J0(DJ_0), .J1(CN_0), .K0(DK_0), .K1(CN_0), .Q(Q[0]), .nQ());

C_LD C_LD1(.EA(DJ_1), .nEA(DK_1), .E(LD), .A(D[1]));
nand #2(nINC_1, Q[0], EN);
nand #2(CN_1, nLD, nINC_1);
SN7472A FF1(.CLK(CLK), .nR(nCLR), .nS(1'b1), .J0(DJ_1), .J1(CN_1), .K0(DK_1), .K1(CN_1), .Q(Q[1]), .nQ());

C_LD C_LD2(.EA(DJ_2), .nEA(DK_2), .E(LD), .A(D[2]));
nand #2(nINC_2, Q[1], Q[0], EN);
nand #2(CN_2, nLD, nINC_2);
SN7472A FF2(.CLK(CLK), .nR(nCLR), .nS(1'b1), .J0(DJ_2), .J1(CN_2), .K0(DK_2), .K1(CN_2), .Q(Q[2]), .nQ());

C_LD C_LD3(.EA(DJ_3), .nEA(DK_3), .E(LD), .A(D[3]));
nand #2(nINC_3, Q[2], Q[1], Q[0], EN);
nand #2(CN_3, nLD, nINC_3);
SN7472A FF3(.CLK(CLK), .nR(nCLR), .nS(1'b1), .J0(DJ_3), .J1(CN_3), .K0(DK_3), .K1(CN_3), .Q(Q[3]), .nQ());

nand #2(nENO, Q[3], Q[2], Q[1], Q[0], EN);
not #2(ENO, nENO);

endmodule

// BCD up counter with 
// count enable Q <- EN ? Q + 1 : Q
// parallel synchronous load  Q <- LD ? D : Q
// and asynchronous clear Q <- nCLR ? Q : 4'b0000
module SN74162(CLK, nCLR, LD, EN, D, Q, ENO);
input CLK, nCLR, LD, EN;
input [3:0] D;
output [3:0] Q;
output ENO;

wire [3:0] nQ;
wire nLD;

not #2 (nLD, LD);
not #2 (nEN, EN);

C_LD C_LD0(.EA(DJ_0), .nEA(DK_0), .E(LD), .A(D[0]));
nand #2(CN_0, nLD, nEN);
SN7472A FF0(.CLK(CLK), .nR(nCLR), .nS(1'b1), .J0(DJ_0), .J1(CN_0), .K0(DK_0), .K1(CN_0), .Q(Q[0]), .nQ(nQ[0]));

C_LD C_LD1(.EA(DJ_1), .nEA(DK_1), .E(LD), .A(D[1]));
nand #2(nINC_1, nQ[3], Q[0], EN);
nand #2(CN_1, nLD, nINC_1);
SN7472A FF1(.CLK(CLK), .nR(nCLR), .nS(1'b1), .J0(DJ_1), .J1(CN_1), .K0(DK_1), .K1(CN_1), .Q(Q[1]), .nQ(nQ[1]));

C_LD C_LD2(.EA(DJ_2), .nEA(DK_2), .E(LD), .A(D[2]));
nand #2(nINC_2, Q[1], Q[0], EN);
nand #2(CN_2, nLD, nINC_2);
SN7472A FF2(.CLK(CLK), .nR(nCLR), .nS(1'b1), .J0(DJ_2), .J1(CN_2), .K0(DK_2), .K1(CN_2), .Q(Q[2]), .nQ(nQ[2]));

C_LD C_LD3(.EA(DJ_3), .nEA(DK_3), .E(LD), .A(D[3]));
nand #2(DS_3, Q[2], Q[1], Q[0], EN);
nand #2(DR_3, Q[3], Q[0], EN);
nand #2(CN_3, nLD, DS_3, DR_3);
SN7472A FF3(.CLK(CLK), .nR(nCLR), .nS(1'b1), .J0(DJ_3), .J1(CN_3), .K0(DK_3), .K1(CN_3), .Q(Q[3]), .nQ(nQ[3]));

nand #2(nENO, Q[3], Q[0], EN);
not #2(ENO, nENO);

endmodule


//Quad D flip-flop triggered on falling edge
module SN7474_4(CLK, nCLR, D, Q);
input CLK;
input nCLR;
input [3:0] D;
output [3:0] Q;

SN7474 FF0(.CLK(CLK), .nR(nCLR), .nS(1'b1), .D(D[0]), .Q(Q[0]), .nQ());
SN7474 FF1(.CLK(CLK), .nR(nCLR), .nS(1'b1), .D(D[1]), .Q(Q[1]), .nQ());
SN7474 FF2(.CLK(CLK), .nR(nCLR), .nS(1'b1), .D(D[2]), .Q(Q[2]), .nQ());
SN7474 FF3(.CLK(CLK), .nR(nCLR), .nS(1'b1), .D(D[3]), .Q(Q[3]), .nQ());

endmodule

module SN74173(CLK, nCLR, EN, D, Q);
input CLK;
input nCLR;
input EN;
input [3:0] D;
output [3:0] Q;
wire FF0_D, FF1_D, FF2_D, FF3_D;

SN74157_1 MX0(.Y(FF0_D), .SEL(EN), .A(Q[0]), .B(D[0]));
SN7474 FF0(.CLK(CLK), .nR(nCLR), .nS(1'b1), .D(FF0_D), .Q(Q[0]), .nQ());
SN74157_1 MX1(.Y(FF1_D), .SEL(EN), .A(Q[1]), .B(D[1]));
SN7474 FF1(.CLK(CLK), .nR(nCLR), .nS(1'b1), .D(FF1_D), .Q(Q[1]), .nQ());
SN74157_1 MX2(.Y(FF2_D), .SEL(EN), .A(Q[2]), .B(D[2]));
SN7474 FF2(.CLK(CLK), .nR(nCLR), .nS(1'b1), .D(FF2_D), .Q(Q[2]), .nQ());
SN74157_1 MX3(.Y(FF3_D), .SEL(EN), .A(Q[3]), .B(D[3]));
SN7474 FF3(.CLK(CLK), .nR(nCLR), .nS(1'b1), .D(FF3_D), .Q(Q[3]), .nQ());

endmodule

//MUX 2 - 1
module SN74157_1(Y, SEL, A, B);
output Y;
input SEL, A, B;

not #2 (nSEL, SEL);
nand #2 (nAS, A, nSEL);
nand #2 (nBS, B,  SEL);
nand #2 (Y, nAS, nBS);

endmodule

//Decoder 1 of 10 active low
module SN7442(Y, I);
input [3:0] I;
output [9:0] Y;

wire [3:0] nI;

not #1 I_INV[3:0](nI, I);
nand #1(Y[0], nI[3], nI[2], nI[1], nI[0]);
nand #1(Y[1], nI[3], nI[2], nI[1],  I[0]);
nand #1(Y[2], nI[3], nI[2],  I[1], nI[0]);
nand #1(Y[3], nI[3], nI[2],  I[1],  I[0]);
nand #1(Y[4], nI[3],  I[2], nI[1], nI[0]);
nand #1(Y[5], nI[3],  I[2], nI[1],  I[0]);
nand #1(Y[6], nI[3],  I[2],  I[1], nI[0]);
nand #1(Y[7], nI[3],  I[2],  I[1],  I[0]);
nand #1(Y[8],  I[3], nI[2], nI[1], nI[0]);
nand #1(Y[9],  I[3], nI[2], nI[1],  I[0]);

endmodule

//Multiplexer 8 lines, 
module SN74151(Y, SEL, I);
output Y;
input [2:0] SEL;
input [7:0] I;

wire [7:0] YE;
wire [2:0] nSEL;

not #1 I_INV[2:0](nSEL, SEL);
nand #2(YE[0], nSEL[2], nSEL[1], nSEL[0], I[0]);
nand #2(YE[1], nSEL[2], nSEL[1],  SEL[0], I[1]);
nand #2(YE[2], nSEL[2],  SEL[1], nSEL[0], I[2]);
nand #2(YE[3], nSEL[2],  SEL[1],  SEL[0], I[3]);
nand #2(YE[4],  SEL[2], nSEL[1], nSEL[0], I[4]);
nand #2(YE[5],  SEL[2], nSEL[1],  SEL[0], I[5]);
nand #2(YE[6],  SEL[2],  SEL[1], nSEL[0], I[6]);
nand #2(YE[7],  SEL[2],  SEL[1],  SEL[0], I[7]);
nand #2(Y, YE[0], YE[1], YE[2], YE[3], YE[4], YE[5], YE[6], YE[7]);

endmodule

// MS D-type flip-flop with 
// asynchronous set and reset both active low
module SN7474(CLK, nR, nS, D, Q, nQ);
input CLK;
input nR, nS; 
input D;
output Q;
output nQ;

not (nCLK, CLK);
nand #2(nDC1,    D, CLK);
nand #2( DC1, nDC1, CLK);
nand #2( Q1, nQ1, nS, nDC1);
nand #2(nQ1,  Q1, nR,  DC1);

nand #2(nS2,  Q1, nCLK);
nand #2(nR2, nQ1, nR, nCLK);
nand #2( Q, nQ, nS2, nS);
nand #2(nQ,  Q, nR2, nR);

endmodule

// MS JK-type flip-flop with 
// asynchronous set and reset both active low
module SN7472(CLK, nR, nS, J, K, Q, nQ);
input CLK;
input nR, nS; 
input J, K;
output Q;
output nQ;

not (nCLK, CLK);

nand #2 G01(JQ, J, nQ);
not  #2 G02(nK, K);
nand #2 G03(KQ, nK, Q);
nand #2 G04(D_JK, JQ, KQ);

nand #2(nDC1, D_JK, CLK);
nand #2( DC1, nDC1, CLK);
nand #2( Q1, nQ1, nS, nDC1);
nand #2(nQ1,  Q1, nR,  DC1);

nand #2(nDC, nCLK, Q1, nR);
nand #2(nQC,  CLK, Q, nR);
nand #2(Q, nDC, nQC, nS);
not  #2(nQ, Q);

endmodule

// MS JK-type flip-flop with
// inputs J0,J1 and K0, K1 passed as product (AND) to J and K
// asynchronous set and reset both active low
module SN7472A(CLK, nR, nS, J0, J1, K0, K1, Q, nQ);
input CLK, nR, nS;
input J0, J1;
input K0, K1;
output Q, nQ;

wire nCLK;
wire Q1, nQ1;
wire D11, D22;
wire JQ, KQ, D_JK;

not G01(nCLK, CLK);

nand #2 G01(JQ, J0, J1, nQ);
nand #2 G02(nK, K0, K1);
nand #2 G03(KQ, nK, Q);
nand #2 G04(D_JK, JQ, KQ);

nand #2(nDC1, D_JK, CLK);
nand #2( DC1, nDC1, CLK);
nand #2( Q1, nQ1, nS, nDC1);
nand #2(nQ1,  Q1, nR,  DC1);

nand #2(nDC, nCLK, Q1, nR);
nand #2(nQC,  CLK, Q, nR);
nand #2(Q, nDC, nQC, nS);
not  #2(nQ, Q);

endmodule

module C_LD(EA, nEA, E, A);
output EA, nEA;
input E, A;

nand #2 (nEA, E, A);
nand #2 (EA, E, nEA);

endmodule

// Frequency generator
// CLK - signal of given frequency
// F - frequency setup
// 
module FREQ_GEN(CLK, F);
parameter F_RES = 1_000_000;
parameter F_RES_2 = 500_000;
parameter F_MAX = 100_000;
output reg CLK;
input [31:0] F; //Requested frequency
integer n;
reg RUN;
time H_PER; //Period
time H_PER_RMD; //Half period reminder
time PER_ACC;

initial begin
    RUN = 1'b0;
    CLK = 1'b0;
end

always @(F) begin
    $display("%m: Frequency set to %d @%t.", F, $time);
    if(^F !== 1'bx) begin
        if(F > F_MAX) begin
            $display("%m : Generator stopped.\nGiven frequency %d is higher than maximal allowed %d.",
                F, F_MAX);
            RUN = 1'b0;
        end
        else begin
            RUN = 1'b1;
        end
    end
    else begin
        $display("%m: Generator stopped on undetermined input.");
        RUN = 1'b0;
    end
end

initial begin
    H_PER_RMD = 0;
    forever begin
        wait(RUN);
        H_PER = F_RES_2 / F;
        PER_ACC = (H_PER * F) + H_PER_RMD;
        if(PER_ACC < F_RES_2) begin
            H_PER = H_PER + 1;
            PER_ACC = PER_ACC + F;
        end
        H_PER_RMD = F_RES_2 - PER_ACC;
        #H_PER;
        CLK = ~CLK;
    end
end

endmodule

