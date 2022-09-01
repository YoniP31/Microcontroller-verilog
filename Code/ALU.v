module ALU(
    input [7:0] i_operand1, i_operand2,
    input i_enable,
    input [3:0] i_mode,
    input [3:0] i_cflags,
    output [7:0] o_out,
    output [3:0] o_flags
);

logic Z,S,O;
logic carry_out;
logic [7:0] out_ALU;

always @(*) begin
case(i_mode)
4'b0000: {carry_out, out_ALU} = i_operand1 + i_operand2;
4'b0001: begin
    out_ALU = i_operand1 - i_operand2;
    carry_out = !out_ALU[7];
end
4'b0010: out_ALU = i_operand1;
4'b0011: out_ALU = i_operand2;
4'b0100: out_ALU = i_operand1 & i_operand2;
4'b0101: out_ALU = i_operand1 | i_operand2;
4'b0110: out_ALU = i_operand1 ^ i_operand2;
4'b0111: begin
    out_ALU = i_operand2 - i_operand1;
    carry_out = !out_ALU[7];
end
4'b1000: {carry_out,out_ALU} = i_operand2 + 8'h1;
4'b1001: begin
    out_ALU = i_operand2 - 8'h1;
    carry_out = !out_ALU[7];
end
4'b1010: out_ALU = (i_operand2 << i_operand1[2:0])|(i_operand2 >> 8 - i_operand1[2:0]);
4'b1011: out_ALU = (i_operand2 >> i_operand1[2:0])|(i_operand2 << 8 - i_operand1[2:0]);
4'b1100: out_ALU = i_operand2 << i_operand1[2:0];
4'b1101: out_ALU = i_operand2 >> i_operand1[2:0];
4'b1110: out_ALU = i_operand2 >>> i_operand1[2:0];
4'b1111: begin
    out_ALU = 8'h0 - i_operand2;
    carry_out = !out_ALU[7];
end
default: out_ALU = i_operand2;
endcase
end
assign Z = (out_ALU == 0)? 1'b1 : 1'b0;
assign S = out_ALU[7];
assign O = out_ALU[7] ^ out_ALU[6];
assign o_flags = {Z,carry_out,S,O};
assign o_out = out_ALU;

endmodule