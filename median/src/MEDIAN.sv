module MEDIAN #(parameter W = 8)(
    input   unsigned    [ W-1 : 0 ] DI,
    input                           DSI,
    input                           nRST,
    input                           CLK,
    output  logic unsigned  [ W-1 : 0 ] DO,
    output                              DSO
);

    enum logic[2:0] { INIT, STORE, SORT, DELETE, MEDIAN } state;
    logic BYP;
    logic [3:0] i=4;
    logic [4:0] j=8;
    logic [4:0] k=4;

    assign DSO = (i==0 && j==0)?1:0;
    assign BYP = (j==0)? 1 : DSI;

    MED #(.W(W), .P(9))inst0 (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));


    always_ff @(posedge CLK or negedge nRST)
        if (!nRST)
            begin
                state <= INIT ;
                k <= 4;
                i <= 4;
                j <= 8;
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
                    SORT : if (j==1)
                            begin
                                if (i==0)
                                    state <= MEDIAN;
                                else
                                    state <= DELETE;
                            end
                    DELETE :
                        if ( k - i == 0 ) begin
                            state <= SORT;
                        end
                    MEDIAN :
                        state <= INIT;
                endcase
                // Les sorties
                if (state == SORT) 
                    begin: loop
                        if ( j > 0 ) 
                            j <= j - 1; 
                    end
                else if (state == DELETE)
                    begin
                        if ( k - i > 0 ) begin
                            k <= k - 1;
                        end else begin
                            i <= i - 1;
                            j <= 9 - (5 - i + 1);
                            k <= 4;
                        end
                    end
                else if (state == MEDIAN) 
                    begin
                        i <= 4;
                        j <= 8;
                        k <= 4;
                    end
            end
endmodule
