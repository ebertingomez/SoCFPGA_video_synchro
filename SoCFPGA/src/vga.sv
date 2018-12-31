`default_nettype none

module vga #(parameter HDISP = 800, parameter VDISP = 480)(
    // External Signals
    input   wire        pixel_clk,
    input   wire        pixel_rst,
    // Signals from the Interface Video
    video_if.master     video_ifm
);

localparam HFP      =   40;
localparam HPULSE   =   48;
localparam HBP      =   40;
localparam VFP      =   13;
localparam VPULSE   =   3;
localparam VBP      =   29;

logic  [$clog2(HDISP+HFP+HPULSE+HBP)-1:0] counterPixels;
logic  [$clog2(VDISP+VFP+VPULSE+VBP)-1:0] counterLines;

assign video_ifm.CLK = pixel_clk;

always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if ( pixel_rst ) 
        {counterPixels,counterLines} <= 0;
        video_ifm.HS <= 1;
        video_ifm.VS <= 1;
        video_ifm.BLANK <= 0;
    else begin
        counterPixels   <= (counterPixels<HDISP+HFP+HPULSE+HBP-1) ? counterPixels+1 : 0;

        if ( counterLines<VDISP+VFP+VPULSE+VBP-1 ) begin
            if (counterPixels==HDISP+HFP+HPULSE+HBP-1)
                counterLines <= counterLines + 1;
        end else begin
            counterLines <= 0;
        end

        video_ifm.HS    <= (HFP-1<=counterPixels && counterPixels<HFP+HPULSE-1)? 0 : 1;
        video_ifm.VS    <= (VFP-1<=counterLines && counterLines<VFP+VPULSE-1)? 0 : 1;
        video_ifm.BLANK <= (counterPixels< HFP+HPULSE+HBP-1 || counterLines< VFP+VPULSE+VBP-1) ? 0 : 1;

        video_ifm.RGB   <= (video_ifm.BLANK && ((counterPixels-HFP-HPULSE-HBP+1)%16==0 || (counterLines-VFP-VPULSE-VBP+1)%16==0)) ? 24'hFFFFFF : 0;

    end
end

    
endmodule