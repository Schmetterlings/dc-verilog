// Perforemd by: {Full Last,First Name}
//
// Task 3. Design a microprogrammable finite state machine controlling the operation 
// of two fans F1 and F2 that provide room ventilation. The room is equipped with 
// two temperature sensors T1 and T2. The Ti sensor gives 1 at its output when 
// the room temperature is equal to or higher than the threshold value ti, 
// where i = 1, 2, and t1 < t2.
// The FSM is to operate according to the following algorithm:
// 1. When the room temperature reaches or exceeds the threshold value t2 (T2 = 1), 
// one of the fans W1 or W2 is to be turned on,
// 2. The currently running fan should be turned off only when the room temperature 
// drops below t1 (T1 = 0),
// 3. The fans W1 and W2 should work alternately.
// Create a testbench to verify circuit operation using a room model in the task file.

`timescale 1ns/100ps

module FAN_CTRL(CLK, CLR, T1, T2, F1, F2);
//Enumerate states using parameters e.g. parameter S1 = 0;
parameter S1 = 2'b00;
parameter S2 = 2'b10;
parameter S3 = 2'b11;
parameter S4 = 2'b01;
//Interface
input CLK, CLR;
input T1, T2;
output F1, F2;

wire [1:0] nextQ;
wire [1:0] Q;
wire sel;
//...
ROM #(.A_W(3), .D_W(4))M1(.A({sel,nextQ}), .Q({Q,F1,F2}));
REG #(.W(2))R1(.CLK(CLK), .CLR(CLR), .D(Q), .Q(nextQ));
//To build an input vector use the concatenation operator {} eg.: .I({T1,T2,...})
MUX4 MUX_1(.Y(sel), .SEL(nextQ), .I({T2,T1,T1,T2}));

initial begin
    //Initialize ROM memory using SET task
    M1.SET({1'b0,S1},{S1,1'b0,1'b0});
    M1.SET({1'b1,S1},{S2,1'b1,1'b0});
    M1.SET({1'b0,S2},{S3,1'b0,1'b0});
    M1.SET({1'b1,S2},{S2,1'b1,1'b0});
    M1.SET({1'b0,S3},{S3,1'b0,1'b0});
    M1.SET({1'b1,S3},{S4,1'b0,1'b1});
    M1.SET({1'b0,S4},{S1,1'b0,1'b0});
    M1.SET({1'b1,S4},{S4,1'b0,1'b1});

end

endmodule

module FAN_CTRL_TEST;

parameter T_LOW = 200;
parameter T_HIGH = 250;
parameter T_HYST = 20;

reg CLK, CLR, T1, T2;
wire F1, F2;

//Unit Under Test
FAN_CTRL UUT(.CLK(CLK), .CLR(CLR), .T1(T1), .T2(T2), .F1(F1), .F2(F2));

//Initialize FUN_CTRL - Pule CLR signal
initial begin
    //Write your test here...    
    CLR= 1'b0;
    #10;
    CLR= 1'b1;
    #100;
    CLR=1'b0;
    repeat(10000) @(negedge CLK);
    $finish;
end

// Clock generator
initial begin
    CLK = 1'b0;
    forever #50 CLK = ~CLK;
end

initial begin
    $dumpfile("fan_ctrl.vcd");
    $dumpvars;
    $dumpon;    
end

//State change reporter ...

//Room temperature model
integer T;
integer CYCLES_CNT;
reg T_INC;

initial begin
    T1 = 1'b0;
    T2 = 1'b0;
    T = 190;
    T_INC = 1'b1;
    CYCLES_CNT = 0;
end

always @(negedge CLK) begin
    if(T_INC) begin
        T = T + 1;
        T_INC = (T < T_HIGH + T_HYST);        
    end
    else begin
        T = T - 1;
        T_INC = (T < T_LOW - T_HYST);        
    end
    T1 = (T >= T_LOW);
    T2 = (T >= T_HIGH);
end

always @(T_INC) begin
    CYCLES_CNT = CYCLES_CNT + 1;
    if(CYCLES_CNT == 11) begin
        repeat(10) @(negedge CLK);
        $display("Simulation finish after %d cycles.", CYCLES_CNT);
        $finish;
    end
end

endmodule
