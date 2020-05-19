`timescale 1ns/100ps

module RAM_16X4(nCS, nWE, nOE, A, D, Q);
parameter T_WE_P = 10;
parameter T_DS = 5;
parameter T_DH = 5;
parameter T_AH = 5;
input nCS; //Chip select - active low
input nOE; //Output enable - active low
input nWE; //Write Enable - active low
input [3:0] A;
input [3:0] D;
output [3:0] Q;

wire [3:0] D_Q;
wire [3:0] A_I;
wire [3:0] D_I;
wire OE_I, WE_I, CS_I;

reg [3:0] MEM [15:0];
time WR_START, WR_END, WR_LEN;
time T_D;
time T_A;

//-------------------------------------------------------------------
// Functional part
//-------------------------------------------------------------------

buf #(2,2) BA[3:0](A_I, A);
buf #(2,2) BD[3:0](D_I, D);
not #(1,1) INV_CS(CS_I, nCS);
not #(1,1) INV_OE(OE_I, nOE);
not #(1,1) INV_WE(WE_I, nWE);

assign D_Q = MEM[A_I];

always @(*) begin
    if(CS_I === 1'b1) begin
        if(WE_I === 1'b1) begin
            MEM[A_I] = D_I;
        end
    end
end

bufif1 #(1,1,2) BQ[3:0](Q, D_Q, (CS_I & & OE_I & ~WE_I));

//-------------------------------------------------------------------
// Behav diagnostics
//-------------------------------------------------------------------

always @(A or nCS or nWE or nOE) begin
    /*if((nCS !== 1'b1) || (nCS !== 1'b0)) begin
        $display("%m(%t): Undetermined state at nCS", $time);
        $stop;
    end*/
    if(nCS === 1'b0) begin
        if((nOE !== 1'b1) && (nOE !== 1'b0)) begin
            $display("%m(%t): Undetermined state at nOE input", $time);
            $stop;
        end
        if((nWE !== 1'b1) && (nWE !== 1'b0)) begin
            $display("%m(%t): Undetermined state at nWE input", $time);
            $stop;
        end
        if((nWE === 1'b0) || (nOE === 1'b0)) begin
            if(^A === 1'bx) begin
                $display("%m(%t): Undetermined state at A input (%b)", $time, A);
                $stop;
            end
        end
    end
end

initial begin
    WR_START = 0;
    T_D = 0;
    T_A = 0;
end

always @(nWE) begin
    if(nWE === 1'b0) begin
        WR_START = $time;
        $display("Data write start: %t", WR_START);
    end
    else if(nWE === 1'b1) begin
        WR_END = $time;        
        WR_LEN = WR_END - WR_START;
        $display("Data write end  : %t (%t)", WR_END, WR_LEN);
        if(WR_LEN < T_WE_P) begin
            $display("%m: Write pulse to short\nObserved: %t\nExpected: %t", WR_LEN, T_WE_P);
        end
        if((WR_END - T_D) < T_DS) begin
            $display("%m: Data setup violation."); 
        end
    end
end

always @(D) begin
    T_D = $time;
    if((T_D - WR_END) < T_DH) begin
        $display("%m(%t): Data hold to short.", T_D);
    end
end

always @(A) begin
    T_A = $time;
    if((T_A - WR_END) < T_AH) begin
        $display("%m(%t): Address hold to short.", T_A);
    end
end

endmodule

module RAM16S(CLK, WE, A, DI, DQ);
parameter W = 4;
input CLK;
input WE;
input [3:0] A;
input [W-1:0] DI;
output [W-1:0] DQ;
reg [W-1:0] MEM[15:0];

integer i;

initial begin
    for(i = 0; i < 16; i = i + 1)
        MEM[i] = {W{1'b0}};
end

always @(posedge CLK)
    if(WE) MEM[A] <= DI;

assign DQ = MEM[A];

endmodule

module RAM16D(CLK, WE, A, AR, DI, DQ);
parameter W = 4;
input CLK;
input WE;
input [3:0] A;
input [3:0] AR;
input [W-1:0] DI;
output [W-1:0] DQ;
reg [W-1:0] MEM[15:0];

integer i;

initial begin
    for(i = 0; i < 16; i = i + 1)
        MEM[i] = {W{1'b0}};
end

always @(posedge CLK)
    if(WE) MEM[A] <= DI;

assign DQ = MEM[AR];

endmodule

module NAND2(Y, A, B);
output Y;
input A, B;

assign #(1) Y = ~(A & B);

endmodule

module NAND3(Y, A, B, C);
output Y;
input A, B, C;

assign #(1) Y = ~(A & B & C);

endmodule

module NAND4(Y, A, B, C, D);
output Y;
input A, B, C, D;

assign #(1) Y = ~(A & B & C & D);

endmodule

module NAND5(Y, A, B, C, D, E);
output Y;
input A, B, C, D, E;

assign #(1) Y = ~(A & B & C & D & E);

endmodule

module NOR2(Y, A, B);
output Y;
input A, B;

assign #(1) Y = ~(A | B);

endmodule

module NOR3(Y, A, B, C);
output Y;
input A, B, C;

assign #(1) Y = ~(A | B | C);

endmodule

module NOR4(Y, A, B, C, D);
output Y;
input A, B, C, D;

assign #(1) Y = ~(A | B | C | D);

endmodule

module NOR5(Y, A, B, C, D, E);
output Y;
input A, B, C, D, E;

assign #(1) Y = ~(A | B | C | D | E);

endmodule

module NOT(Y, A);
output Y;
input A;

assign #(1) Y = ~A;

endmodule

module CB(CLK, CLR, CE, Q);
parameter W = 4;
input CLK, CE, CLR;
output reg [W-1:0] Q;

always @(posedge CLK) begin
    if(CLR)
        Q <= #1 {W{1'b0}};
    else begin
        if(CE) 
            Q <= #1 (Q + 1);
    end
end

endmodule

module CBUD(CLK, CLR, CE, UP, Q);
parameter W = 4;
input CLK, CLR, CE, UP;
output reg [W-1:0] Q;

always @(posedge CLK) begin
    if(CLR)
        Q <= #1 {W{1'b0}};
    else if(CE) begin
        if(UP)
            Q <= #1 (Q + 1);
        else
            Q <= #1 (Q - 1);
    end
end

endmodule

module ADD(CO, S, A, B, CI);
parameter W = 8;
output [W-1:0] S;
output CO;
input  [W-1:0] A, B;
output CI;

assign #1 {CO, S} = A + B + CI;

endmodule

module FDCE(CLK, CLR, CE, D, Q);
parameter W = 8;
input CLK, CLR, CE;
input [W-1:0] D;
output [W-1:0] Q;
reg [W-1:0] Q;

always @(posedge CLK or posedge CLR) begin
    if(CLR)
        Q <= #1 {W{1'b0}};
    else
        Q <= #1 D;
end

endmodule
