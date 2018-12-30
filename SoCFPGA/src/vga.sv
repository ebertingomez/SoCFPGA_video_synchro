`default_nettype none

module vga #(parameter HDISP = 800, parameter VDISP = 480)(
    // External Signals
    input   wire        pixel_clk,
    input   wire        pixel_rst,
    // Signals from the Interface Video
    video_if.master     video_ifm
);

localparam HFP=40;
localparam HPULSE=48;
localparam HBP=40;
localparam VFP=13;
localparam VPULSE=3;
localparam VBP=29;

logic  [$clog2(HDISP+HFP+HPULSE+HBP)-1:0] counterPixels;
logic  [$clog2(VDISP+VFP+VPULSE+VBP)-1:0] counterLines;

assign video_ifm.CLK = pixel_clk;

always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if ( pixel_rst ) 
        {counterPixels,counterLines} <= 0;
    else begin
        counterPixels <= (counterPixels<HDISP+HFP+HPULSE+HBP) ? counterPixels+1 : 0;
        counterLines <= (counterPixels<VDISP+VFP+VPULSE+VBP) ? counterLines+1 : 0;

        video_ifm.HS <= (HFP<counterPixels && counterPixels<HFP+HPULSE)? 0 : 1;
        video_ifm.VS <= (VFP<counterLines && counterLines<VFP+VPULSE)? 0 : 1;
        video_ifm.BLANK <= (counterPixels< HFP+HPULSE+HBP || counterLines< VFP+VPULSE+VBP) ? 0 : 1;

        video_ifm.RGB <= (video_ifm.BLANK && ((counterPixels-HFP-HPULSE-HBP)%16==0 || (counterLines-VFP-VPULSE-VBP)%16==0)) ? 24'hFFFFFF : 0;

    end
end

    
endmodule