class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_tlm_analysis_fifo #(seq_item) wrt_fifo;   // from write-fifo monitor
  uvm_tlm_analysis_fifo #(seq_item) rd_fifo;   // from read-fifo monitor

  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wrt_fifo = new("wrt_fifo", this);
    rd_fifo = new("rd_mon_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item wrt,rd;
      wrt = seq_item::type_id::create("wrt");
      rd  = seq_item::type_id::create("rd");
      fork
      wrt_fifo.get(wrt);
      rd_fifo.get(rd);
  join
  end
  endtask

endclass
