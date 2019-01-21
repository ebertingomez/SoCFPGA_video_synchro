`default_nettype none
module wshb_intercon (
    wshb_if.slave      wshb_ifs_mire,
    wshb_if.slave      wshb_ifs_vga,
    // Signals from the Interface Wishbone
    wshb_if.master      wshb_ifm
);
    // This is the token
    logic mireActive;

    assign wshb_ifs_vga.dat_sm  = wshb_ifm.dat_sm;
    assign wshb_ifm.dat_ms      = wshb_ifs_mire.dat_ms;

    assign wshb_ifs_mire.ack    = (mireActive)  ? wshb_ifm.ack : '0;
    assign wshb_ifs_vga.ack     = (~mireActive) ? wshb_ifm.ack : '0;

    assign wshb_ifm.cyc         = (mireActive)  ? wshb_ifs_mire.cyc : wshb_ifs_vga.cyc ;
    assign wshb_ifm.stb         = (mireActive)  ? wshb_ifs_mire.stb : wshb_ifs_vga.stb ;
    assign wshb_ifm.we          = (mireActive)  ? wshb_ifs_mire.we  : wshb_ifs_vga.we  ;
    assign wshb_ifm.adr         = (mireActive)  ? wshb_ifs_mire.adr : wshb_ifs_vga.adr ;
    assign wshb_ifm.sel         = (mireActive)  ? wshb_ifs_mire.sel : wshb_ifs_vga.sel ;
    assign wshb_ifm.cti         = (mireActive)  ? wshb_ifs_mire.cti : wshb_ifs_vga.cti ;
    assign wshb_ifm.bte         = (mireActive)  ? wshb_ifs_mire.bte : wshb_ifs_vga.bte ;

    /*
    always @(*)
    begin
        if ( wshb_ifm.rst ) begin
            mireActive          = 1'b1;
        end else begin
            mireActive          = (~wshb_ifm.cyc) ? ~mireActive : mireActive;
        end
    end
    */

    always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
    begin
        if ( wshb_ifm.rst ) begin
            mireActive          <= 1'b0;
        end else begin
            mireActive          <= (~wshb_ifm.cyc) ? ~mireActive : mireActive;
        end
    end



endmodule