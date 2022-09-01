//TACTL
/*bits 0-3: clock input divider 01 /1, 10 /2, 100 /4, 110 /6, 1000 /8...
  bit 4: enable timer
  bits 5-6: 00 Stop mode: the timer is halted
            01 Up mode: the timer counts up to TAC
            10 Continuous mode: the timer counts up to 0FFh
            11 Up/down mode: the timer counts up to TAC then down to 00h
*/

module TIMER_A(
    input i_clk,
    input [6:0] i_TACTL,
    input [7:0] i_TAC,
    input [1:0] i_mode,
    output reg [7:0] o_TA
);

logic [7:0] TA_out = 8'h0;
logic enable = 1;
logic U_D_flag = 0;

always @(posedge i_clk) begin
    if(enable) begin
        case(i_mode)
        2'b00: TA_out <= 0;
        2'b01: begin
            if(TA_out > (i_TAC - 1)) begin
                TA_out <= 8'h0;
                enable <= 0;
            end else begin
                TA_out <= TA_out + 8'h1;
                enable <= 1;
            end
        end
        2'b10: begin
            if(TA_out > 'hFE) begin
                TA_out <= 0;
                enable <= 0;
            end else begin
                TA_out <= TA_out + 8'h1;
                enable <= 1;
            end
        end
        2'b11: begin
            if((U_D_flag == 0)) begin
                if(TA_out < i_TAC) begin
                    TA_out <= TA_out + 8'h1;
                    enable <= 1;
                end else U_D_flag <= 1;
            end 
            else begin
                if(TA_out > 8'h0)
                    TA_out <= TA_out - 8'h1;
                else
                    enable <= 0;
            end
        end
        endcase
    end
end


assign o_TA = TA_out;

endmodule