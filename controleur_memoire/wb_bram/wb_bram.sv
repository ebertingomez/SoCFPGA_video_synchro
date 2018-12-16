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

      assign wb_s.ack = (wb_s.stb && wb_s.we) | ack_read;

      always_ff @(posedge wb_s.clk)
      begin
            if ( wb_s.stb && wb_s.we )
                  case(wb_s.sel)
                        4'b0001: memory[wb_s.adr[mem_adr_width+1:2]][0] <= wb_s.dat_ms[7:0];
                        4'b0010: memory[wb_s.adr[mem_adr_width+1:2]][1] <= wb_s.dat_ms[15:8];
                        4'b0100: memory[wb_s.adr[mem_adr_width+1:2]][2] <= wb_s.dat_ms[23:16];
                        4'b1000: memory[wb_s.adr[mem_adr_width+1:2]][3] <= wb_s.dat_ms[31:24];
                        4'b0011: memory[wb_s.adr[mem_adr_width+1:2]][1:0] <= wb_s.dat_ms[15:0];
                        4'b1100: memory[wb_s.adr[mem_adr_width+1:2]][3:2] <= wb_s.dat_ms[31:16];
                        4'b1111: memory[wb_s.adr[mem_adr_width+1:2]] <= wb_s.dat_ms;
                  endcase
            else if (wb_s.stb && ~wb_s.we && ~wb_s.ack)
                  wb_s.dat_sm <= {memory[wb_s.adr[mem_adr_width+1:2]]};

            ack_read <= (ack_read) ? 0 : (wb_s.stb && ~wb_s.we);
      end
      
endmodule

