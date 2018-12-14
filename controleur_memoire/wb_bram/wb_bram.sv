//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre 
// de mots de la mémoire : (2048 pour mem_adr_width=11)

module wb_bram #(parameter mem_adr_width = 11) (
      // Wishbone interface
      wshb_if.slave wb_s
      );
      // a vous de jouer a partir d'ici
      logic [3:0][7:0] memory [0: 2**mem_adr_width - 1];
      logic ack_read;
      logic [mem_adr_width -1 : 0] address;
      logic [mem_adr_width -1 : 0] i;


      assign address = wb_s.adr[mem_adr_width+1:2] + i;
      assign wb_s.ack = (wb_s.stb && wb_s.we) | ack_read;


      always_ff @(posedge wb_s.clk or posedge wb_s.rst)
      begin
            if (wb_s.rst)
            begin
                  i <= 0;
                  ack_read <= 0;
            end
            else if ( wb_s.stb && wb_s.we )
                  case(wb_s.sel)
                        4'b0001: memory[address][0] <= wb_s.dat_ms[7:0];
                        4'b0010: memory[address][1] <= wb_s.dat_ms[15:8];
                        4'b0100: memory[address][2] <= wb_s.dat_ms[23:16];
                        4'b1000: memory[address][3] <= wb_s.dat_ms[31:24];
                        4'b0011: memory[address][1:0] <= wb_s.dat_ms[15:0];
                        4'b1100: memory[address][3:2] <= wb_s.dat_ms[31:16];
                        4'b1111: memory[address] <= wb_s.dat_ms;
                  endcase
            else if (wb_s.stb && ~wb_s.we)
            begin 
                  wb_s.dat_sm <= {memory[address]};

                  if ( wb_s.cti != 0)
                        case(wb_s.cti)
                              3'b001: ack_read <= 1'b1;
                              3'b010: begin
                                    ack_read <= 1'b1;
                                    i <= 1;
                              end 
                              3'b111: begin
                                    ack_read <= (~ack_read) ? 1'b1 : 1'b0;
                                    i <= 0;
                              end 
                        endcase
                  else begin 
                        ack_read <= (ack_read) ? 0 : (wb_s.stb && ~wb_s.we);
                        i <= 0;
                  end
            end
      end
      
endmodule

