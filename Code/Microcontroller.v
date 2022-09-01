`include "ALU.v"
`include "Data_Memory.v"
`include "Control_Logic.v"
`include "MUX1 + Adder.v"
`include "Program_Memory.v "
`include "Clock_Divider.v"
`include "Timer_A.v"
`include "Comparator.v"
`include "UART_RX.v"
`include "UART_TX.v"
`include "Watchdog_Timer.v"

module MICROCONTROLLER(
    input clk, rst, wdt_rst, RX_clk, TX_clk,
    input [6:0] TACTL,
    input [7:0] TAC,
    output [7:0] o_PC
);

parameter LOAD = 2'b00, FETCH = 2'b01, DECODE = 2'b10, EXECUTE = 2'b11;

logic [1:0] current_state, next_state;
logic [13:0] program_mem[9:0];
logic load_done;
logic [7:0] load_addr;
logic [13:0] load_instr;
logic [7:0] PC, DR, Acc;
logic [13:0] IR;
logic [3:0] SR;
logic PC_E, Acc_E, SR_E, DR_E, IR_E, DIV_E;
logic PC_clr, Acc_clr, SR_clr, DR_clr, IR_clr;
logic [7:0] PC_updated, DR_updated;
logic [13:0] IR_updated;
logic [3:0] SR_updated;
logic PMEM_E,DMEM_E,DMEM_WE,ALU_E,PMEM_LE,MUX1_Sel,MUX2_Sel,MUX3_sel;
logic [3:0] ALU_Mode;
logic [7:0] Adder_Out;
logic [7:0] ALU_Out,ALU_Oper2;
logic [7:0] DMEM_in;

//divided clock
logic div_clk;

//Timer A
logic [7:0] TA_out;

//Comparator
logic COMP_E;
logic oper1_less_oper2;
logic oper1_equal_oper2;
logic oper1_greater_oper2;

//UART TX
logic TX_ready;
logic TX_done;
logic TX_reset;
logic TX_out;

//UART RX
logic RX_done;
logic RX_reset;
logic RX_in;
logic [7:0] RX_out;
logic [3:0] i = 4'd3;
logic RX_PC_E;

initial begin
    $readmemb("program_mem.dat", program_mem,0,9);
end

ALU ALU_unit( .i_operand1(Acc),
              .i_operand2(ALU_Oper2),
              .i_enable(ALU_E),
              .i_mode(ALU_Mode),
              .i_cflags(SR),
              .o_out(ALU_Out),
              .o_flags(SR_updated)
);

MUX1 MUX2_unit( .i_input2(IR[7:0]),
                .i_input1(DR),
                .i_select(MUX2_Sel),
                .o_out(ALU_Oper2)
);

DATA_MEMORY DATA_MEMORY_unit( .clk(clk),
                              .i_enable(DMEM_E),
                              .i_write_enable(DMEM_WE),
                              .i_address(IR[3:0]),
                              .i_data_input(DMEM_in),
                              .o_data_out(DR_updated)
);

PROGRAM_MEMORY PROGRAM_MEMORY_unit( .clk(clk),
                                    .i_enable(PMEM_E),
                                    .i_address(PC),
                                    .o_instruction(IR_updated),
                                    .i_load_enable(PMEM_LE),
                                    .i_load_address(load_addr),
                                    .i_load_instruction(load_instr)
);

ADDER ADDER_unit( .i_input(PC),
                  .o_out(Adder_Out)
);

MUX1 MUX1_unit( .i_input1(Adder_Out),
                .i_input2(IR[7:0]),
                .i_select(MUX1_Sel),
                .o_out(PC_updated)
);

CONTROL_LOGIC CONTROL_LOGIC_unit( .rx_clk(RX_clk),
                                  .stage(current_state),
                                  .IR(IR),
                                  .SR(SR),
                                  .PC_E(PC_E),
                                  .Acc_E(Acc_E),
                                  .SR_E(SR_E),
                                  .IR_E(IR_E),
                                  .DR_E(DR_E),
                                  .ALU_E(ALU_E),
                                  .MUX1_Sel(MUX1_Sel),
                                  .MUX2_Sel(MUX2_Sel),
                                  .MUX3_sel(MUX3_Sel),
                                  .DMEM_E(DMEM_E),
                                  .DMEM_WE(DMEM_WE),
                                  .PMEM_LE(PMEM_LE),
                                  .PMEM_E(PMEM_E),
                                  .ALU_Mode(ALU_Mode),
                                  .COMP_E(COMP_E),
                                  .rx_reset(RX_reset),
                                  .tx_reset(TX_reset),
                                  .rx_PC_E(RX_PC_E),
                                  .rx_done(RX_done),
                                  .tx_done(TX_done),
                                  .tx_ready(TX_ready)
);

CLOCK_DIVIDER CLOCK_DIVIDER_unit( .i_clk(clk),
                                  .i_enable(TACTL[4]),
                                  .i_div(TACTL[3:0]),
                                  .o_div_clk(div_clk)
);

TIMER_A TIMER_A_unit( .i_clk(div_clk),
                      .i_TACTL(TACTL),
                      .i_TAC(TAC),
                      .i_mode(TACTL[6:5]),
                      .o_TA(TA_out)
);

COMPARATOR COMPARATOR_unit( .i_operand1(Acc[3:0]),
                            .i_operand2(IR[3:0]),
                            .i_enable(COMP_E),
                            .o_oper1_less_oper2(oper1_less_oper2),
                            .o_oper1_equal_oper2(oper1_equal_oper2),
                            .o_oper1_greater_oper2(oper1_greater_oper2)
);

UART_TX UART_TX_unit( .i_clk(TX_clk),
                      .i_tx_data(DR),
                      .i_tx_ready(TX_ready),
                      .i_reset_n(TX_reset),
                      .o_tx_done(TX_done),
                      .o_tx_out(TX_out)
);

UART_RX UART_RX_unit( .i_clk(RX_clk),
                      .i_rx_in(RX_in),
                      .i_reset_n(RX_reset),
                      .o_rx_done(RX_done),
                      .o_rx_out(RX_out)
);

MUX1 MUX3_unit( .i_input1(RX_out),
                .i_input2(ALU_Out),
                .i_select(MUX3_Sel),
                .o_out(DMEM_in)
);

//RX UART
always @(posedge clk) begin
    if(IR[13] != 1) begin
        RX_in <= 1;
    end
    else if(IR[13] == 1 && IR[12] == 1 && (RX_done == 0)) begin
        if(i == 4'd3) begin
            RX_PC_E <= 0;
            RX_in <= 0;
            i <= i + 4'd1;
        end
        else if(i == 4'd12) begin
            RX_PC_E <= 1;
            i <= i + 4'd1;
        end
        else if(i == 4'd13) begin
            i <= 4'd3;
        end
        else begin
            RX_in <= IR[i];
            i <= i + 4'd1;
        end
    end
end

//LOAD
always @(posedge clk) begin
    if(rst == 1) begin
        load_addr <= 8'd0;
        load_done <= 1'b0;
    end
    else if(PMEM_LE == 1) begin
        load_addr <= load_addr + 8'd1;
        if(load_addr == 8'd9) begin
            load_addr <= 8'd0;
            load_done <= 1'b1;
        end
        else begin
            load_done <= 1'b0;
        end
    end
end

assign load_instr = program_mem[load_addr];

assign o_PC = PC;

//next state
always @(posedge clk) begin
    if(rst == 1) 
        current_state <= LOAD;
    else
        current_state <= next_state;
end

always @(*) begin
    PC_clr = 0;
    Acc_clr = 0;
    SR_clr = 0;
    DR_clr = 0;
    IR_clr = 0;
    case(current_state)
    LOAD: begin
        if(load_done == 1) begin
            next_state = FETCH;
            PC_clr = 1;
            Acc_clr = 1;
            SR_clr = 1;
            DR_clr = 1;
            IR_clr = 1;
        end
        else 
            next_state = LOAD;
    end
    FETCH: begin
        next_state = DECODE;
    end
    DECODE: begin
        next_state = EXECUTE;
    end
    EXECUTE: begin
        next_state = FETCH;
    end
    endcase
    if(wdt_rst == 1) begin
        PC_clr = 1;
        Acc_clr = 1;
        SR_clr = 1;
        DR_clr = 1;
        IR_clr = 1;
        next_state = LOAD;
    end
end

//3 programmer visible registers
always @(posedge clk) begin 
    if(rst == 1) begin
        PC <= 8'd0;
        Acc <= 8'd0;
        SR <= 4'd0;
    end
    else begin
        if(PC_E == 1'd1)
            PC <= PC_updated;
        else if(PC_clr == 1)
            PC <= 8'd0;
        if(Acc_E == 1'd1)
            Acc <= ALU_Out;
        else if(Acc_clr == 1)
            Acc <= 8'd0;
        if(SR_E == 1'd1)
            SR <= SR_updated;
        else if(SR_clr == 1)
            SR <= 4'd0;
    end
end

//2 programmer invisible registers
always @(posedge clk) begin
    if(DR_E == 1'd1)
        DR <= DR_updated;
    else if(DR_clr == 1)
        DR <= 8'd0;
    if(IR_E == 1'd1)
        IR <= IR_updated;
    else if(IR_clr == 1)
        IR <= 12'd0;
end

endmodule