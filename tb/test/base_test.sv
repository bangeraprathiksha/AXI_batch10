//--------------------------------------------------------------------------------------------
// Class: base_test
// FIXED vs original:
//   - was building "env" (broken class), now builds top_env (cpu_env + axi_vip_env)
//   - ADDED run_phase: starts top_vseq on the virtual sequencer, so the test
//     actually drives traffic instead of just elaborating and doing nothing
//--------------------------------------------------------------------------------------------
class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  top_env env_h;

  function new(string name = "base_test",
               uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = top_env::type_id::create("env_h", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    top_vseq seq;
    phase.raise_objection(this);

    seq = top_vseq::type_id::create("seq");
    if (!seq.randomize() with { num_txns == 10; })
      `uvm_error(get_type_name(), "randomize failed")
    seq.start(env_h.vseqr_h);

    phase.drop_objection(this);
  endtask

endclass
