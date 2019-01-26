`default_nettype none
module mire #(parameter HDISP = 800, parameter VDISP = 480)(
    // Signals from the Interface Wishbone
    wshb_if.master      wshb_ifm
);

logic [$clog2(HDISP*VDISP)-1:0] counter;

assign wshb_ifm.we      = 1'b1;
assign wshb_ifm.sel     = 4'b1111;
assign wshb_ifm.cti     = '0 ;
assign wshb_ifm.bte     = '0 ;

assign wshb_ifm.cyc     = wshb_ifm.stb;


always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
    // Reset of the bus.
    if ( wshb_ifm.rst ) begin
        {counter , wshb_ifm.adr , wshb_ifm.dat_ms}    <= '0;
        wshb_ifm.stb <= 1'b1;
    end else begin
        // We start to count only if the strobe is active
        if ( wshb_ifm.stb ) begin
            wshb_ifm.stb    <= ((counter+1) % 64 == '0) ? 1'b0 : 1'b1;
        end else begin
            wshb_ifm.stb    <= 1'b1;
        end
        // Burst bus cycle Wishbone. We handle the counter and the communication with the SDRAM
        // Only if the strobe is active we increment the counter and the addr.
        // The mire is an array of vertical lines equally spaced.
        if ( counter + wshb_ifm.ack <  HDISP*VDISP) begin
            wshb_ifm.adr    <= wshb_ifm.adr + 4 * wshb_ifm.ack;
            counter         <= counter + wshb_ifm.ack;
            wshb_ifm.dat_ms <= (counter%16=='0) ? 32'hFFFFFF : 32'h000000 ;
        end else begin
            {wshb_ifm.adr,counter} <= '0;
        end
    end
end
    
endmodule