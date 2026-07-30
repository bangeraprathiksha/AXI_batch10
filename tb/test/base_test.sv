class base_test extends uvm_test;
 `uvm_component_utils(base_test)

  top_env tenv;
  cpu_write_seq seq;


 function new(string name="test", uvm_component parent);
  super.new(name,parent);
 endfunction 


 function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  tenv = environment::type_id::create("tenv", this);
  seq = cpu_write_seq::type_id::create("seq");
 endfunction 

 function void end_of_elaboration();
 uvm_top.print_topology();
 endfunction


 task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  if (!seq.randomize() with { num_txns == 10; })
      `uvm_error(get_type_name(), "randomize failed")
   seq.start(tenv.vseqr);
 phase.drop_objection(this);
 endtask  
    
endclass
