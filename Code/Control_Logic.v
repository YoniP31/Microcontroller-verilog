module CONTROL_LOGIC(
    input rx_clk,
    input [1:0] stage,
    input [13:0] IR,
    input [3:0] SR,
    input rx_PC_E, rx_done, tx_done,
    output reg PC_E, Acc_E, SR_E, IR_E, DR_E, PMEM_E, DMEM_E, DMEM_WE,
    output reg COMP_E, ALU_E, MUX1_Sel, MUX2_Sel, MUX3_sel, PMEM_LE,
    output reg rx_reset, tx_reset, tx_ready,
    output reg [3:0] ALU_Mode
);

parameter LOAD = 2'b00, FETCH = 2'b01, DECODE = 2'b10, EXECUTE = 2'b11;

always @(*) begin
    PC_E = 0;
    Acc_E = 0;
    SR_E = 0;
    IR_E = 0;
    DR_E = 0;
    PMEM_E = 0;
    PMEM_LE = 0;
    DMEM_E = 0;
    DMEM_WE = 0;
    ALU_E = 0;
    MUX1_Sel = 0;
    MUX2_Sel = 0;
    MUX3_sel = 0;
    ALU_Mode = 4'h0;
    COMP_E = 0;
    rx_reset = 1;
    tx_reset = 1;
    tx_ready = 0;
    if(stage == LOAD) begin
        PMEM_LE = 1;
        PMEM_E = 1;
    end
    else if(stage == FETCH) begin
        IR_E = 1;
        PMEM_E = 1;
    end
    else if(stage == DECODE) begin
        if(IR[11:9] == 3'b001) begin //M-type instructions
            DR_E = 1;
            DMEM_E = 1;
        end
        else begin
            DR_E = 0;
            DMEM_E = 0;
        end
    end
    else if(stage == EXECUTE) begin
        if(IR[13] == 1'b0) begin
            if(IR[11] == 1'b1) begin //I-type ALU instructions
                PC_E = 1;
                Acc_E = 1;
                SR_E = 1;
                ALU_E = 1;
                ALU_Mode = IR[10:8];
                MUX1_Sel = 1;
                MUX2_Sel = 0;
            end
            else if(IR[10] == 1'b1) begin //conditional branch (JZ,JC,JS,JO)
                PC_E = 1;
                MUX1_Sel = SR[IR[9:8]];
            end
            else if(IR[9] == 1'b1) begin //M-type ALU instructions
                PC_E = 1;
                Acc_E = IR[8];
                SR_E = 1;
                DMEM_E = !IR[8];
                DMEM_WE = !IR[8];
                ALU_E = 1;
                ALU_Mode = IR[7:4];
                MUX1_Sel = 1;
                MUX2_Sel = 1;
            end
            else if(IR[8] == 1'b1) begin //unconditional jump(GOTO)
                PC_E = 1;
                MUX2_Sel = 0;
            end
            else if(IR[8] == 1'b0) begin //special instructions(NOP)
                PC_E = 1;
                MUX1_Sel = 1;   
                if(IR[4]  == 1'b1)
                    COMP_E = 1;
            end
            else begin
                PC_E = 1;
                MUX1_Sel = 0;
            end
        end
        else if(IR[12] == 1'b1) begin
            MUX3_sel = 1;
            DMEM_E = 1;
            DMEM_WE = 1;
            MUX1_Sel = 1;
            PC_E = 0;
            if(rx_PC_E == 1) begin
                PC_E = 1;
            end
        end
        else if(IR[12] == 1'b0) begin
            DR_E = 1;
            DMEM_E = 1;
            tx_ready = 1;
            PC_E = 0;
            MUX1_Sel = 1;
            if(tx_done == 1)
                PC_E = 1;
        end
    end
end
endmodule