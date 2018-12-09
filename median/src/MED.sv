module MED #(parameter W = 8, parameter P = 9)(
    input           [W - 1 : 0] DI,
    input                       DSI,
    input                       BYP,
    input                       CLK,
    output     [W - 1 : 0] DO
);

    logic unsigned [ W-1 : 0] R [P - 1 : 0];
    logic unsigned [ W-1 : 0] min, max;
    wire unsigned [ W-1 : 0] din;

    assign din = (DSI) ? DI : min;

    assign DO = R[P - 1];

    MCE #(.W(W))inst0 (.A(DO), .B( R[P - 2] ), .MIN(min), .MAX(max));

    always_ff @(posedge CLK)
    begin
        R[P - 1] <= (BYP) ? R[P - 2] : max;
        for (int i = P - 2; i > 0; i--) begin
            R[i] <= R[i-1];
        end
        R[0] <= din;
    end

endmodule
