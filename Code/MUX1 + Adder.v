module MUX1(
    input [7:0] i_input1, i_input2,
    input i_select,
    output [7:0] o_out
);

assign o_out = (i_select == 1)? i_input1 : i_input2;

endmodule

module ADDER(
    input [7:0] i_input,
    output [7:0] o_out
);

assign o_out = i_input + 1'b1;

endmodule