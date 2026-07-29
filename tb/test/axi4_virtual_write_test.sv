//--------------------------------------------------------------------------------------------
// Class: axi4_virtual_write_test
// NEW FILE. Requested testcase #1: runs the virtual sequence so that the
// AXI4 slave write sequence and the CPU write sequence run together
// (not the old single-sequencer/single-cpu-only flow in base_test).
//--------------------------------------------------------------------------------------------
class axi4_virtual_write_test extends base_test;

  `uvm_component_utils(axi4_virtual_write_test)

  function new(string name = "axi4_virtual_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi4_virtual_write_seq seq;
    phase.raise_objection(this);

    seq = axi4_virtual_write_seq::type_id::create("seq");
    if (!seq.randomize() with { num_txns == 10; })
      `uvm_error(get_type_name(), "randomize failed")
      seq.start(tenv.vseqr);
    phase.drop_objection(this);
  endtask

endclass
