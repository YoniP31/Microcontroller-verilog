//CLKS_PER_BIT = (Frequency of i_clock)/(Frequency of UART)

module UART_RX #(
    parameter CLKS_PER_BIT = 2,
    parameter DATA_WIDTH   = 8
    ) (
        input                   i_clk,
        input                   i_rx_in,
        input                   i_reset_n,
        output                  o_rx_done,
        output [DATA_WIDTH-1:0] o_rx_out
    ); 

parameter CNT_WIDTH = DATA_WIDTH;
parameter INDEX = $clog2(DATA_WIDTH);

//States:
parameter s_idle         = 3'b000;
parameter s_rx_start_bit = 3'b001;
parameter s_rx_data_bits = 3'b010;
parameter s_rx_stop_bit  = 3'b011;
parameter s_cleanup      = 3'b100;

logic       q1_rx_data;
logic       q2_rx_data;

logic [2:0]            state;
logic [CNT_WIDTH-1:0]  counter;
logic                  rx_done;
logic [INDEX-1:0]      rx_bit_index;
logic [DATA_WIDTH-1:0] rx_out;

//Crossing the input data to the UART RX clock domain,
//to remove the problems of metastability
always @(posedge i_clk) begin
    q1_rx_data <= i_rx_in;
    q2_rx_data <= q1_rx_data;
end

//control RX state machine
always @(posedge i_clk) begin
    case(state)
        s_idle: begin
            rx_done <= 1'b0;
            counter <= 'b0;
            rx_bit_index <= 'b0;
            if(q2_rx_data == 1'b0) begin //start bit detected
                state <= s_rx_start_bit;
            end else begin
                state <= s_idle;
            end
        end

        //waiting until the middle of the bit cycle to make sure it is still low
        s_rx_start_bit: begin
            if(counter == ((CLKS_PER_BIT - 1)/2)) begin
                if(q2_rx_data == 1'b0) begin
                    counter <= 'b0;     //if bit still low reset counter
                    state <= s_rx_data_bits;
                end else begin
                    state <= s_rx_start_bit;
                end
            end else begin
                counter <= counter + 1;
                state <= s_rx_start_bit;
            end
        end

        //wait CLK_PER_BIT-1 clock cycles to sample serial data
        s_rx_data_bits: begin
            if(counter < CLKS_PER_BIT - 1) begin
                counter <= counter + 1;
                state <= s_rx_data_bits;
            end else begin 
                counter <= 'b0;
                rx_out[rx_bit_index] <= q2_rx_data;
                if(rx_bit_index < DATA_WIDTH-1) begin
                    rx_bit_index <= rx_bit_index + 1;
                    state <= s_rx_data_bits;
                end else begin
                    rx_bit_index <= 'b0;
                    state <= s_rx_stop_bit;
                end
            end
        end

        //recieve stop bit. stop bit = 1
        s_rx_stop_bit: begin
            //wait CLK_PER_BIT-1 clock cycles for stop bit to finish
            if(counter < CLKS_PER_BIT - 1) begin
            counter <= counter + 1;
            state <= s_rx_stop_bit; 
            end else begin
                rx_done <= 1'b1;
                counter <= 'b0;
                state <= s_cleanup;
            end
        end

        s_cleanup: begin
            state <= s_idle;
            rx_done <= 1'b0;
        end

        default: 
            state <= s_idle;

    endcase
end

//reset logic
always @(negedge i_reset_n) begin
    state <= s_idle;
    rx_done <= 1'b0;
    counter <= 'b0;
end

assign o_rx_done = rx_done;
assign o_rx_out = rx_out;

endmodule