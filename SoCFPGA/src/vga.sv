`default_nettype none

module vga #(parameter HDISP = 800, parameter VDISP = 480)(
    // External Signals
    input   wire        pixel_clk,
    input   wire        pixel_rst,
    // Signals from the Interface
    video_if.master     video_ifm
);

localparam HFP=40;
localparam HPULSE=48;
localparam HBP=40;
localparam VFP=13;
localparam VPULSE=3;
localparam VBP=29;

logic  [$clog2(HDISP)-1:0] counterPixels;
logic  [$clog2(VDISP)-1:0] counterLines;

assign video_ifm.CLK = pixel_clk;

always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if ( pixel_rst ) 
        {counterPixels,counterLines} <= 0;
    else begin
        
    end
end

    
endmodule