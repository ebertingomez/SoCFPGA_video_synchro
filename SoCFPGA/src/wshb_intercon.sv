`default_nettype none
module wshb_intercon (
    wshb_if.slave      wshb_ifs_mire,
    wshb_if.slave      wshb_ifs_vga,
    // Signals from the Interface Wishbone
    wshb_if.master      wshb_ifm
);
    // This is the token for the mire. If it is negative it means the VGA has it.
    logic mireActive;

    // Value assignation. 
    assign wshb_ifs_vga.dat_sm  = wshb_ifm.dat_sm;
    assign wshb_ifm.dat_ms      = wshb_ifs_mire.dat_ms;

    // Handling of ack. It is important to reset it when we pass the token.
    assign wshb_ifs_mire.ack    = (mireActive)  ? wshb_ifm.ack : '0;
    assign wshb_ifs_vga.ack     = (~mireActive) ? wshb_ifm.ack : '0;

    // Assignation of the other signals in function of the token.
    // It's important to note that the cyc will resynchronize with the token.
    // SO if the mire or the VGA have the token is because their CYC is 1 or the one
    // of their counterpart is 0
    assign wshb_ifm.cyc         = (mireActive)  ? wshb_ifs_mire.cyc : wshb_ifs_vga.cyc ;
    assign wshb_ifm.stb         = (mireActive)  ? wshb_ifs_mire.stb : wshb_ifs_vga.stb ;
    assign wshb_ifm.we          = (mireActive)  ? wshb_ifs_mire.we  : wshb_ifs_vga.we  ;
    assign wshb_ifm.adr         = (mireActive)  ? wshb_ifs_mire.adr : wshb_ifs_vga.adr ;
    assign wshb_ifm.sel         = (mireActive)  ? wshb_ifs_mire.sel : wshb_ifs_vga.sel ;
    assign wshb_ifm.cti         = (mireActive)  ? wshb_ifs_mire.cti : wshb_ifs_vga.cti ;
    assign wshb_ifm.bte         = (mireActive)  ? wshb_ifs_mire.bte : wshb_ifs_vga.bte ;

    always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
    begin
        if ( wshb_ifm.rst ) begin
            mireActive          <= 1'b0;
        end else begin
            // We pass the token if the CYC signal of the current user (mire or VGA) is 0
            mireActive          <= (~wshb_ifm.cyc) ? ~mireActive : mireActive;
        end
    end



endmodule