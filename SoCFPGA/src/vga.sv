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
// Horizontal parameters in pixels for synchronosation
localparam HFP      =   40;
localparam HPULSE   =   48;
localparam HBP      =   40;
// Vertical parameters  in lines for synchronisation
localparam VFP      =   13;
localparam VPULSE   =   3;
localparam VBP      =   29;

// Signals for the FIFO
wire   rclk; 
wire   read;
logic  [23:0] rdata;
logic  rempty;
wire   write;
logic  wfull;
logic  walmost_full;

// Video Interface Clock
assign video_ifm.CLK = pixel_clk;

// Video Controller and Reading FIFO
logic  [$clog2(HDISP+HFP+HPULSE+HBP)-1:0] counterPixels;
logic  [$clog2(VDISP+VFP+VPULSE+VBP)-1:0] counterLines;
logic   adder;

// Variables for the re-synchronisation
logic old_wfull, pipe,new_wfull, was_wfull;

assign video_ifm.RGB    = rdata;
// We read the FIFO only not ignored (NOT BLANK) values
assign read		        = video_ifm.BLANK;
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if ( pixel_rst ) 
    begin
        // Initialisation of the values of all the signals
        {counterPixels,counterLines,video_ifm.BLANK,adder}  <= '0;
        {pipe,new_wfull, was_wfull}                         <= '0;
        {video_ifm.HS,video_ifm.VS}                         <= 2'b11;
    end
    else begin
        // Clock domain resolution
        {new_wfull,pipe}<= {pipe,wfull};
        was_wfull       <= (was_wfull || new_wfull) ? 1'b1 : 1'b0;

        // Counters evolution
        // Once the FIFO was full for the first time, we start the counter for the screen.
        // It means the we start to count the synchro bits.
        counterPixels   <= (counterPixels<HDISP+HFP+HPULSE+HBP-1 && was_wfull) ? counterPixels+1 : '0;
        counterLines    <= (counterLines<VDISP+VFP+VPULSE+VBP) ? counterLines+adder : '0;
        // Relative adder to line number
        adder           <= (counterPixels==HDISP+HFP+HPULSE+HBP-3) ? 1'b1 : 1'b0 ;

        // management of signal of temporal synchronisation  
        video_ifm.HS    <= (HFP-1<=counterPixels && counterPixels<HFP+HPULSE-1)? 1'b0 : 1'b1;
        video_ifm.VS    <= (VFP<=counterLines && counterLines<VFP+VPULSE)? 1'b0 : 1'b1;
        video_ifm.BLANK <= (counterPixels == HDISP+HFP+HPULSE+HBP-1 || counterPixels< HFP+HPULSE+HBP-1 || counterLines< VFP+VPULSE+VBP) ? 1'b0 : 1'b1;        

    end
end

// Reading process on the SDRAM
logic [$clog2(HDISP*VDISP)-1:0] counterSDRAM;
// Wisbone Interface signals
assign wshb_ifm.dat_ms  = 32'hBABECAFE ;
assign wshb_ifm.sel     = 4'b1111 ;
// We validate a lecture process only if the FIFO is not full
assign  wshb_ifm.stb    = ~wfull;
// Read-only
assign  wshb_ifm.we     = 1'b0;
assign  wshb_ifm.bte    = 2'b00;
assign  wshb_ifm.cti    = 3'b010;

// CYC management
always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
    if ( wshb_ifm.rst ) wshb_ifm.cyc    <= 1'b1;
    else wshb_ifm.cyc <= (walmost_full && was_wfull) ? 1'b0 : 1'b1 ;
end 

// Reading process on the SDRAM
always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
    if ( wshb_ifm.rst ) begin
        {wshb_ifm.adr,counterSDRAM}    <= '0;
        
    end else begin
        // Burst bus cycle Wishbone. We handle the counter and the communication with the SDRAM
        // Only if the strobe is active we increment the counter and the addr.
        if ( counterSDRAM + wshb_ifm.ack <  HDISP*VDISP) begin
            wshb_ifm.adr    <= (wshb_ifm.stb) ? wshb_ifm.adr + 4 * wshb_ifm.ack : wshb_ifm.adr;
            counterSDRAM    <= (wshb_ifm.stb) ? counterSDRAM + wshb_ifm.ack : counterSDRAM;
        end else begin
            {wshb_ifm.adr,counterSDRAM} <= 2'b00;
        end
    end
end


// Writing on FIFO
// Instanciation of ASYNC_FIFO
assign write = wshb_ifm.ack & wshb_ifm.stb;
async_fifo #(.DATA_WIDTH(24), .ALMOST_FULL_THRESHOLD(224)) async_fifo_inst(
    .rst    (wshb_ifm.rst),             // Reading reset
    .rclk   (pixel_clk),                // Reading clock. The same than the pixel
    .read   (read),                     // Read order
    .rdata  (rdata),                    // Data read
    .rempty (rempty),                   // Reading EMpty
    .wclk   (wshb_ifm.clk),             // Writing clock, the same as the RAM
    .wdata  (wshb_ifm.dat_sm[23:0]),    // Data to write is sent by the RAM
    .write  (write),                    // Write order
    .wfull  (wfull),                    // The FIFO is full
    .walmost_full (walmost_full)
);

endmodule
	
