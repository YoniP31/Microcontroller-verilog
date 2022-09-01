module COMPARATOR(
    input [3:0] i_operand1,
    input [3:0] i_operand2,
    input i_enable,
    output reg o_oper1_less_oper2,
    output reg o_oper1_equal_oper2,
    output reg o_oper1_greater_oper2
);

always @(*) begin
    if(i_enable) begin
        if(i_operand1 < i_operand2) begin
            o_oper1_equal_oper2 = 0;
            o_oper1_greater_oper2 = 0;
            o_oper1_less_oper2 = 1;
        end
        else if(i_operand1 == i_operand2) begin
            o_oper1_equal_oper2 = 1;
            o_oper1_greater_oper2 = 0;
            o_oper1_less_oper2 = 0;
        end
        else if(i_operand1 > i_operand2) begin
            o_oper1_equal_oper2 = 0;
            o_oper1_greater_oper2 = 1;
            o_oper1_less_oper2 = 0;
        end
    end
end

endmodule