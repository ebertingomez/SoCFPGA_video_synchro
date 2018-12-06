/**
    This module is used to compare two pixels and return the maximun and minimum value of them.
*/
module MCE #(parameter WIDTH = 8)(
    input   unsigned [WIDTH - 1 :0] A,
    input   unsigned [WIDTH - 1 :0] B,
    output  unsigned [WIDTH - 1 :0] MIN,
    output  unsigned [WIDTH - 1 :0] MAX
);
assign {MAX,MIN} = (A>B) ? {A,B} : {B,A};
    
endmodule