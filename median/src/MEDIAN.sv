/**
    @brief This module is used to get the median of an array of 9 pixels.
    The data is entered through the wire DI. DSI allowd to store data. When the median of
    an array of values has been found, the bit DSO is set to 1 and the value is
    sent using DO.
*/
module MEDIAN #(parameter W = 8)(
    input   unsigned    [ W-1 : 0 ] DI,
    input                           DSI,
    input                           nRST,
    input                           CLK,
    output  logic unsigned  [ W-1 : 0 ] DO,
    output                              DSO
);
    /**
        List of states.
        TODO: Delete the state INIT 
    */
    enum logic[2:0] { INIT, STORE, SORT, DELETE, MEDIAN } state;
    // Variable to control the MED module.
    logic BYP;
    // Variables to control the loop after each clock period
    logic [3:0] i;
    logic [4:0] j;
    logic [4:0] k;

    // This condition holds when the loop finishes (when the median has been found)
    assign DSO = (i==0 && j==0) ? 1 : 0 ;
    // BYP is set to 0 after the max value is found. Otherwise, its value is the same as DSI
    assign BYP = (j==0)? 1 : DSI;
    // Initialization of the module MED
    MED #(.W(W), .P(9))inst0 (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));


    always_ff @(posedge CLK or negedge nRST)
        // We reinitialize the values when reset is pushed.
        if (!nRST)
            begin
                state <= INIT ;
                k <= 4;
                i <= 4;
                j <= 8;
            end
        else
            begin
                // The transtions of the stattes
                /* verilator lint_off CASEINCOMPLETE */
                case (state) 
                    INIT: if (DSI == 1)
                        begin
                            state <= STORE;
                        end
                    // If DSI is 0, we start to sort the values
                    STORE : if (DSI == 0)
                        state <= SORT;
                    // When we find a max of a iteration, we either delete the value or send it as the median
                    SORT : if (j==1)
                            begin
                                if (i==0)
                                    state <= MEDIAN;
                                else
                                    state <= DELETE;
                            end
                    DELETE :
                    /* We need to take of the offset values generated at the beginning of the arrays
                    when the delete the max */
                        if ( k - i == 0 ) begin
                            state <= SORT;
                        end
                    MEDIAN :
                        state <= INIT;
                endcase
                // The outputs
                if (state == SORT) 
                    begin: loop
                        if ( j > 0 ) 
                            j <= j - 1; 
                    end
                // We take take of the offset after the previous deletion
                else if (state == DELETE)
                    begin
                        if ( k - i > 0 ) begin
                            k <= k - 1;
                        // or set the variable for the new interation
                        end else begin
                            i <= i - 1;
                            j <= 9 - (5 - i + 1);
                            k <= 4;
                        end
                    end
                // We prepare the values for the next arrays of values.
                else if (state == MEDIAN) 
                    begin
                        i <= 4;
                        j <= 8;
                        k <= 4;
                    end
            end
endmodule
