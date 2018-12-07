/**
    This module is used to compare two pixels and return the maximun and minimum value of them.
*/
module MCE #(parameter W = 8)(
    input   unsigned [W - 1 :0] A,
    input   unsigned [W - 1 :0] B,
    output  unsigned [W - 1 :0] MIN,
    output  unsigned [W - 1 :0] MAX
);
    assign {MAX,MIN} = (A>B) ? {A,B} : {B,A};
    
endmodule