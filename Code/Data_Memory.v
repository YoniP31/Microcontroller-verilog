module DATA_MEMORY(
    input clk,
    input i_enable,
    input i_write_enable,
    input [3:0] i_address,
    input [7:0] i_data_input,
    output [7:0] o_data_out
);

logic [7:0] data_mem [255:0];

always @(posedge clk) begin
    if(i_enable == 1 && i_write_enable == 1) begin
        data_mem[i_address] <= i_data_input; 
    end
end

assign o_data_out = (i_enable == 1)? data_mem[i_address] : 0;

endmodule