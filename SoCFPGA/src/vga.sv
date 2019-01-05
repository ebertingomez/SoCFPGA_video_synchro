`default_nettype none

module vga #(parameter HDISP = 800, parameter VDISP = 480)(
    // External Signals
    input   wire        pixel_clk,
    input   wire        pixel_rst,
    // Signals from the Interface Video
    video_if.master     video_ifm,
    // Signals from the Interface Wishbone
    wshb_if.master      wshb_ifm
);

// Local temporal parameters for the display. 
// Horizontal parameters are in pixels and vertical ones are in lines
localparam HFP      =   40;
localparam HPULSE   =   48;
localparam HBP      =   40;
localparam VFP      =   13;
localparam VPULSE   =   3;
localparam VBP      =   29;

logic  [$clog2(HDISP+HFP+HPULSE+HBP)-1:0] counterPixels;
logic  [$clog2(VDISP+VFP+VPULSE+VBP)-1:0] counterLines;
logic   adder;

// Signals for the FIFO
wire   rclk; 
wire   read;
logic  rdata;
logic  rempty;
wire   write;
logic  wfull;
logic  walmost_full;

// Video Interface Clock
assign video_ifm.CLK = pixel_clk;

// Wisbone Interface signals
assign wshb_ifm.dat_ms  = 32'hBABECAFE ;
assign wshb_ifm.sel     = 4'b1111 ;
assign wshb_ifm.cti     = '0 ;
assign wshb_ifm.bte     = '0 ;

always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if ( pixel_rst ) 
    begin
        // Initialisation of the values of all the signals
        {counterPixels,counterLines,video_ifm.BLANK,adder} <= '0;
        {video_ifm.HS,video_ifm.VS} <= 2'b11;
    end
    else begin
        // Counters evolutions
        counterPixels   <= (counterPixels<HDISP+HFP+HPULSE+HBP-1) ? counterPixels+1 : '0;
        counterLines    <= (counterLines<VDISP+VFP+VPULSE+VBP) ? counterLines+adder : '0;
        // Relative adder to the line number
        adder           <= (counterPixels==HDISP+HFP+HPULSE+HBP-3) ? 1'b1 : 1'b0 ;

        // Temporal synchronisation signals management
        video_ifm.HS    <= (HFP-1<=counterPixels && counterPixels<HFP+HPULSE-1)? 1'b0 : 1'b1;
        video_ifm.VS    <= (VFP<=counterLines && counterLines<VFP+VPULSE)? 1'b0 : 1'b1;
        video_ifm.BLANK <= (counterPixels == HDISP+HFP+HPULSE+HBP-1 || counterPixels< HFP+HPULSE+HBP-1 || counterLines< VFP+VPULSE+VBP) ? 1'b0 : 1'b1;

        // Pixels generation
        video_ifm.RGB   <= (video_ifm.BLANK && ((counterPixels-HFP-HPULSE-HBP+1)%16==0 || (counterLines-VFP-VPULSE-VBP)%16==0)) ? 24'hFFFFFF : 0;

    end
end

// Reading process on the SDRAM
logic [$clog2(HDISP*VDISP)-1:0] counterSDRAM;
logic [23:0]                    pixel;
logic 				            pre_ack;

assign  wshb_ifm.stb    = ~wfull;
assign  wshb_ifm.we     = 1'b0;


always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
    if ( wshb_ifm.rst ) begin
        wshb_ifm.cyc    <= 1'b1;
        {wshb_ifm.adr,counterSDRAM,pre_ack}    <= '0;
    end else begin
	    pre_ack		    <= wshb_ifm.ack;
        // Classic bus cycle Wishbone
        if ( counterSDRAM + wshb_ifm.ack <  HDISP*VDISP ) begin
            if (~pre_ack) begin
                wshb_ifm.adr    <= wshb_ifm.adr + 4 * wshb_ifm.ack;
                counterSDRAM    <= counterSDRAM + wshb_ifm.ack;
            end
        end else begin
            if (wshb_ifm.ack && ~pre_ack) begin
                    {wshb_ifm.adr,counterSDRAM} <= 2'b00;
            end
        end
    end
end

// Writing on FIFO
// Instanciation of ASYNC_FIFO
assign write = wshb_ifm.ack & ~pre_ack;
async_fifo #(.DATA_WIDTH(24)) async_fifo_inst(
    .rst    (wshb_ifm.rst), 
    .rclk   (rclk), 
    .read   (read), 
    .rdata  (rdata), 
    .rempty (rempty), 
    .wclk   (wshb_ifm.clk), 
    .wdata  (wshb_ifm.dat_sm[23:0]), 
    .write  (write), 
    .wfull  (wfull),
    .walmost_full (walmost_full)
);


    
endmodule
	
