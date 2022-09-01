`timescale 1ns/1ns
`include "Microcontroller.v"

module MCU_tb;

logic clk;
logic rst;
logic wdt_rst;
logic rx_clk;
logic tx_clk;
logic [7:0] PC;
logic [6:0] TACTL;
logic [7:0] TAC;
 
MICROCONTROLLER DUT(.clk(clk),
                    .RX_clk(rx_clk),
                    .TX_clk(tx_clk),
                    .rst(rst),
                    .wdt_rst(wdt_rst),
                    .TACTL(TACTL),
                    .TAC(TAC),
                    .o_PC(PC)
);

WATCHDOG_TIMER WATCHDOG_TIMER_unit( .i_clk(clk),
                                    .i_pc(PC),
                                    .o_reset(wdt_rst)
);

initial begin
    rst = 1;
    #50;
    rst = 0;
end

initial begin
    clk = 0;
    rx_clk = 0;
    tx_clk = 0;
end

always #10 clk = ~clk;
always #5 rx_clk = ~rx_clk;
always #5 tx_clk = ~tx_clk;

initial begin
    $dumpfile("MCU.vcd");
    $dumpvars(0, MCU_tb);

    TACTL = 7'b1010001;
    TAC = 8'hA;

    #2000;

    $display("test complete");
    $finish;
    
end

endmodule