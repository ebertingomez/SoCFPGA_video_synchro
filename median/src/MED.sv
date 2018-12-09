/**
    @brief This module is used to get the max value of an array of numbers. It is used
    to find the median of a given set of numbers when setting DSI and BYP correctly.

*/
module MED #(parameter W = 8, parameter P = 9)(
    input           [W - 1 : 0] DI,
    input                       DSI,
    input                       BYP,
    input                       CLK,
    output     [W - 1 : 0] DO
);
    /**
        The array used to store the input values 
    */
    logic unsigned [ W-1 : 0] R [P - 1 : 0];
    logic unsigned [ W-1 : 0] min, max;
    /**
        This wire will represent the most recent input and will be connected to the first register
    */
    wire unsigned [ W-1 : 0] din;

    assign din = (DSI) ? DI : min;

    assign DO = R[P - 1];
    /**
        Initialization of the module MCE
    */
    MCE #(.W(W))inst0 (.A(DO), .B( R[P - 2] ), .MIN(min), .MAX(max));

    always_ff @(posedge CLK)
    begin
        // Output value. Last register
        R[P - 1] <= (BYP) ? R[P - 2] : max;
        for (int i = P - 2; i > 0; i--) begin
            //Intermediate registers
            R[i] <= R[i-1];
        end
        // Input Value. First register
        R[0] <= din;
    end

endmodule
