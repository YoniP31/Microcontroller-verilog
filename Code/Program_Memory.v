module PROGRAM_MEMORY(
    input clk,
    input i_enable,
    input [7:0] i_address,
    output [13:0] o_instruction,
    input i_load_enable,
    input [7:0] i_load_address,
    input [13:0] i_load_instruction

);

logic [13:0] prog_mem [255:0];
//Load instruction into program memory
always @(posedge clk) begin
    if(i_load_enable == 1)
        prog_mem[i_load_address] <= i_load_instruction;  
end

assign o_instruction = (i_enable == 1)? prog_mem[i_address] : 0;

endmodule