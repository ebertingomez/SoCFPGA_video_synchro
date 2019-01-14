`default_nettype none

module Top #(parameter HDISP = 800, parameter VDISP = 480)(
    // Les signaux externes de la partie FPGA
	input  wire         FPGA_CLK1_50,
	input  wire  [1:0]	KEY,
	output logic [7:0]	LED,
	input  wire	 [3:0]	SW,
    // Les signaux du support matériel son regroupés dans une interface
    hws_if.master       hws_ifm,
    // Signals from the Interface Video
    video_if.master     video_ifm
);

//====================================
//  Déclarations des signaux internes
//====================================
  wire        sys_rst;   // Le signal de reset du système
  wire        sys_clk;   // L'horloge système a 100Mhz
  wire        pixel_clk; // L'horloge de la video 32 Mhz

//=======================================================
//  La PLL pour la génération des horloges
//=======================================================

sys_pll  sys_pll_inst(
		   .refclk(FPGA_CLK1_50),   // refclk.clk
		   .rst(1'b0),              // pas de reset
		   .outclk_0(pixel_clk),    // horloge pixels a 32 Mhz
		   .outclk_1(sys_clk)       // horloge systeme a 100MHz
);

//=============================
//  Les bus Wishbone internes
//=============================
wshb_if #( .DATA_BYTES(4)) wshb_if_mire  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_vga  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_sdram  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_stream (sys_clk, sys_rst);

//=============================
//  Le support matériel
//=============================
hw_support hw_support_inst (
    .wshb_ifs (wshb_if_sdram),
    .wshb_ifm (wshb_if_stream),
    .hws_ifm  (hws_ifm),
	.sys_rst  (sys_rst), // output
    .SW_0     ( SW[0] ),
    .KEY      ( KEY )
 );

//=============================
// On neutralise l'interface
// du flux video pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_stream.ack = 1'b1;
assign wshb_if_stream.dat_sm = '0 ;
assign wshb_if_stream.err =  1'b0 ;
assign wshb_if_stream.rty =  1'b0 ;

//=============================
// On neutralise l'interface SDRAM
// pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
// assign wshb_if_sdram.stb  = 1'b0;
// assign wshb_if_sdram.cyc  = 1'b0;
// assign wshb_if_sdram.we   = 1'b0;
// assign wshb_if_sdram.adr  = '0  ;
// assign wshb_if_sdram.dat_ms = '0 ;
// assign wshb_if_sdram.sel = '0 ;
// assign wshb_if_sdram.cti = '0 ;
// assign wshb_if_sdram.bte = '0 ;

//--------------------------
//------- Code Eleves ------
//--------------------------

// Set clock frequency for simulation and synthesis
`ifdef SIMULATION
  localparam hcmpt = 9 ;
`else
  localparam hcmpt = 26 ;
`endif


assign LED[0] = KEY[0];
// Counter for LED 1
logic [hcmpt:0] counter;
assign LED[1]   = counter[hcmpt];

// Pixel reset
logic [1:0] Q;
wire pixel_rst;
assign pixel_rst = Q[1];

// Counter for LED 2
logic [hcmpt-2:0] counterLCD;
assign LED[2]   = counterLCD[hcmpt-2];

// Counter for LED 1
always_ff @(posedge sys_clk or posedge sys_rst)
begin
    counter     <= ( sys_rst ) ? 0 : counter + 1; 
end

// Pixel reset
always_ff @(posedge pixel_clk or posedge sys_rst)
begin
    Q           <= ( sys_rst ) ? 2'b11 :Q << 1;
end

// Counter for LED 2
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    counterLCD  <= ( pixel_rst ) ? 0 : counterLCD + 1; 
end

// Instantiation of VGA
vga #(.HDISP(HDISP), .VDISP(VDISP) ) vga_inst(
	.pixel_clk      (pixel_clk ), // Clock for the VGA
    .pixel_rst      (pixel_rst ), // Reset 
    .video_ifm      (video_ifm), // Interface which contains all the signals for the display
    .wshb_ifm       (wshb_if_vga.master) // Interface with the wishbone signals
);

mire #(.HDISP(HDISP), .VDISP(VDISP) ) mire_inst(
    .wshb_ifm       (wshb_if_mire.master) // Interface with the wishbone signals
);

wshb_intercon  wshb_intercon_inst(
	.wshb_ifs_mire  (wshb_if_vga.slave), // Interface with the wishbone signals
    .wshb_ifs_vga   (wshb_if_mire.slave), // Interface with the wishbone signals
    .wshb_ifm       (wshb_if_sdram.master) // Interface with the wishbone signals
);


endmodule
