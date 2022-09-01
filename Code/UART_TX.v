//CLKS_PER_BIT = (Frequency of i_clk)/(Frequency of UART)

module UART_TX #(
    parameter CLKS_PER_BIT = 2,
    parameter DATA_WIDTH = 8
) (
    input                  i_clk,
    input [DATA_WIDTH-1:0] i_tx_data,
    input                  i_tx_ready,
    input                  i_reset_n,
    output reg             o_tx_done,
    output reg             o_tx_out
);

parameter CNT_WIDTH = DATA_WIDTH;
parameter INDEX = $clog2(DATA_WIDTH);
//states:
parameter s_idle         = 3'b000;
parameter s_tx_start_bit = 3'b001;
parameter s_tx_data_bits = 3'b010;
parameter s_tx_stop_bit  = 3'b011;
parameter s_cleanup      = 3'b100;

logic [INDEX-1:0]      state;
logic [DATA_WIDTH-1:0] tx_data;
logic [CNT_WIDTH-1:0]  counter;
logic [INDEX-1:0]      tx_bit_index;
logic                  tx_done;

always @(posedge i_clk) begin
    case(state)
        s_idle: begin
            o_tx_out <= 'b1; //drive the output to high for idle
            counter <= 'b0;
            tx_bit_index <= 'b0;
            tx_done <= 'b0;
            if(i_tx_ready) begin
                tx_data <= i_tx_data;
                state <= s_tx_start_bit;
            end else begin
                state <= s_idle;
            end
        end

        s_tx_start_bit: begin
            o_tx_out <= 'b0;
            if(counter < CLKS_PER_BIT - 1) begin
                counter <= counter + 1;
                state <= s_tx_start_bit;
            end else begin
                counter <= 'b0;
                state <= s_tx_data_bits;
            end
        end

        s_tx_data_bits: begin
            o_tx_out <= i_tx_data[tx_bit_index];
            if(counter < CLKS_PER_BIT - 1) begin
                counter <= counter + 1;
                state <= s_tx_data_bits;
            end else begin
                counter <= 'b0;
                if(tx_bit_index < DATA_WIDTH-1) begin
                    tx_bit_index <= tx_bit_index + 1;
                    state <= s_tx_data_bits;
                    if(tx_bit_index == DATA_WIDTH-2) begin
                        tx_done <= 1;
                    end
                end else begin
                    tx_bit_index <= 'b0;
                    state <= s_tx_stop_bit;
                end
            end
        end

        //send stop bit = 1
        s_tx_stop_bit: begin
            o_tx_out <= 'b1;
            //wait for one clock cycle to finish stop bit
            if(counter < CLKS_PER_BIT - 1) begin
                counter <= counter + 1;
                state <= s_tx_stop_bit;
            end else begin
                counter <= 0;
                o_tx_out <= 'b1;
                tx_done <= 'b1;
                state <= s_cleanup;
            end
        end

        s_cleanup: begin
            tx_done <= 'b0;
            state <= s_idle;
        end

        default: begin
            state <= s_idle;
        end
    endcase
end

always @(negedge i_reset_n) begin
    state <= s_idle;
    counter <= 0;
    tx_done <= 0;    
end

assign o_tx_done = tx_done;

endmodule