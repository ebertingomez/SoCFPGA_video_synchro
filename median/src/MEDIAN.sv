module MEDIAN #(parameter W = 8)(
    input   unsigned    [ W-1 : 0 ] DI,
    input                           DSI,
    input                           nRST,
    input                           CLK,
    output  logic unsigned  [ W-1 : 0 ] DO,
    output                              DSO
);

    enum logic[2:0] { INIT, STORE, SORT, DELETE, MEDIAN } state, n_state;

    logic BYP, outp;
    logic [3:0]i=5;
    logic [4:0] j=9;

    MED #(.W(W), .P(9))inst0 (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));

    assign DSO = (1==1)?outp:0;
    assign BYP = (j==0)? 1 : DSI;

    always_ff @(posedge CLK or posedge nRST)
        if (!nRST)
            begin
                state <= INIT ;
                outp <= 0;
            end
        else
            begin
                // Les transitions
                /* verilator lint_off CASEINCOMPLETE */
                case (state) 
                    INIT: if (DSI == 1)
                        begin
                            state <= STORE;
                        end
                    STORE : if (DSI == 0 && BYP == 0)
                        state <= SORT;
                    SORT : if (BYP == 1)
                            begin
                                if (i==0)
                                    state <= MEDIAN;
                                else
                                    state <= DELETE;
                            end
                    DELETE :
                        state <= SORT;
                    MEDIAN :
                        state <= INIT;
                endcase
                // Les sorties
                if (state == INIT || state == STORE)  
                    outp <= 0;
                else if (state == SORT) 
                    begin
                        if ( i > 0) begin
                            if ( j > 0 ) begin
                                j <= j - i;
                            end else begin
                                i <= i - 1;
                                j <= 9 - (5 - i);
                            end
                        end else begin
                            outp <= 1;
                        end
                    end
                else if (state == DELETE) 
                    begin
                        outp <= 0;
                    end
                else if (state == MEDIAN) 
                    begin
                        i <= 5;
                        j <= 9;
                        outp <= 0;
                    end
            end
endmodule