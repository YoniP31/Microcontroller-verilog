module CLOCK_DIVIDER(
    input i_clk,
    input i_enable,
    output reg o_div_clk,
    input [3:0] i_div
);
//0001 -> /1  //0011 -> /3
//0010 -> /2  //0101 -> /5
//0100 -> /4  //0111 -> /7
//0110 -> /6     ...
//1000 -> /8

logic [4:0] counter1 = 0;
logic [4:0] counter2 = 0;
logic div_clk1, div_clk2;

//dividing on positive edge of clock
always @(posedge i_clk) begin
    if(i_enable && (i_div > 0)) begin
        counter1 <= counter1 + 4'd1;
        if(counter1 >= (i_div - 1))
            counter1 <= 4'd0;
        div_clk1 <= (counter1 < (i_div/2))? 1'b1 : 1'b0;
    end
end

//dividing on negetive edge of clock
always @(negedge i_clk) begin
    if(i_enable && (i_div > 0)) begin
        counter2 <= counter2 + 4'd1;
        if(counter2 >= (i_div - 1))
            counter2 <= 4'd0;
        div_clk2 <= (counter2 < (i_div/2))? 1'b1 : 1'b0;
    end
end

//if number of divisiom is 1, it stays the reguler clock.
//else, if number of division is odd, combine posedge and negedge signals to recieve 50% duty cycle
assign o_div_clk = (i_div == 4'd1)? i_clk : ((i_div % 2) == 0)? div_clk1 : !(div_clk1 | div_clk2);
endmodule