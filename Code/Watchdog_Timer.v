module WATCHDOG_TIMER #(parameter CC_COUNT = 16)(
    input i_clk,
    input [7:0] i_pc,
    output reg o_reset
);

parameter COUNTER_WIDTH = $clog2(CC_COUNT);
logic [COUNTER_WIDTH-1:0] counter = CC_COUNT;
logic [7:0] temp_pc;

always @(posedge i_clk) begin
    o_reset <= 0;
    if(counter == 4'd15) begin
        temp_pc <= i_pc;
        counter <= counter - 4'd1;
    end
    if(i_pc == temp_pc) begin
        if(counter == 4'd0) begin
            o_reset <= 1;
            counter <= 4'd0;
        end
        counter <= counter - 4'b1;
    end
    else
        counter <= 4'd15;
end

endmodule