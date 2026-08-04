//--------------------------------------------------------------------------------------------
// Classes: top_vseqr, top_vseq
// NEW FILES. Virtual sequencer + virtual sequence so the test can "run the
// virtual sequences" as requested, rather than starting cpu_write_seq directly
// on the cpu sequencer from the test.
//--------------------------------------------------------------------------------------------
class top_vseqr extends uvm_sequencer;
  `uvm_component_utils(top_vseqr)

  cpu_sequencer               cpu_sqr_h;         // set by top_env.connect_phase
  // ADDED: handles to the AXI4 slave VIP's own write/read sequencers, so a
  // virtual sequence started on this vseqr can drive the slave-side
  // sequence and the cpu-side sequence together, instead of only cpu_sqr_h.
  axi4_slave_write_sequencer  slave_write_sqr_h; // set by top_env.connect_phase
  axi4_slave_read_sequencer   slave_read_sqr_h;  // set by top_env.connect_phase

  function new(string name = "top_vseqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass


class top_vseq extends uvm_sequence;
  `uvm_object_utils(top_vseq)
  `uvm_declare_p_sequencer(top_vseqr)

  rand int unsigned num_txns = 10;

  function new(string name = "top_vseq");
    super.new(name);
  endfunction

  task body();
     cpu_write_seq wseq;
    repeat (num_txns) begin
      wseq = cpu_write_seq::type_id::create("wseq");
      wseq.start(p_sequencer.cpu_sqr_h);
    end
  endtask
endclass
