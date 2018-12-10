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
      logic ack_read;
      // Ecriture
      assign wb_s.ack = (wb_s.stb && wb_s.we) | ack_read;

      // Lecture
      always_ff @(posedge wb_s.clk)
            if ( CTI != 0 ) begin
                  case(CTI)
                        3'b001: begin 
                                    ack_read <= 1;
                              end
                        3'b010: begin 
                                    ack_read <= 1;
                              end
                        3'b111: ack_read <= 0;
                  endcase
            end else begin
                  ack_read <= (ack_read) ? 0 : (wb_s.stb && ~wb_s.we);
            end
      
endmodule

