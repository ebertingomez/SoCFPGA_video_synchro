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
      logic tmp_ack;
      // Ecriture
      assign wb_s.ack = (wb_s.stb && wb_s.we && wb_s.cyc) ? 1 : tmp_ack;

      // Lecture
      always_ff @(posedge wb_s.clk)
      begin
            tmp_ack <= (wb_s.stb && ~wb_s.we && wb_s.cyc);
      end
            

endmodule

