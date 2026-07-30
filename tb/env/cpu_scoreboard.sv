class cpu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(cpu_scoreboard)

  uvm_tlm_analysis_fifo #(cpu_seq_item) cpu_imp;   // from write-fifo monitor
  uvm_tlm_analysis_fifo #(cpu_seq_item) slave_imp;   // from read-fifo monitor

  function new(string name="cpu_scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cpu_imp = new("cpu_imp", this);
    slave_imp = new("slave_imp", this);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      cpu_seq_item wrt,rd;
      wrt = cpu_seq_item::type_id::create("wrt");
      rd  = cpu_seq_item::type_id::create("rd");
      fork
      cpu_imp.get(wrt);
      slave_imp.get(rd);
  join
  end
  endtask

endclass
