//--------------------------------------------------------------------------------------------
// Class: axi4_virtual_read_test
// NEW FILE. Requested testcase #2: runs the virtual sequence so that the
// AXI4 slave read sequence and the CPU read sequence run together.
//
// Reads what the write test put in (same DUT memory/FIFO underneath), so
// run axi4_virtual_write_test before this one in the same regression run
// if you want the reads to hit real data rather than default/zero content.
//--------------------------------------------------------------------------------------------
class axi4_virtual_read_test extends base_test;

  `uvm_component_utils(axi4_virtual_read_test)

  function new(string name = "axi4_virtual_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi4_virtual_read_seq seq;
    phase.raise_objection(this);

    seq = axi4_virtual_read_seq::type_id::create("seq");
    if (!seq.randomize() with { num_txns == 10; })
      `uvm_error(get_type_name(), "randomize failed")
      seq.start(tenv.vseqr);

    phase.drop_objection(this);
  endtask

endclass
