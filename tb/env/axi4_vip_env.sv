class axi_vip_env extends uvm_env;
 
  `uvm_component_utils(axi_vip_env)
 
  axi4_slave_agent        slave_agt_h;

  axi4_slave_agent_config slave_agt_cfg_h;
 
  function new(string name = "axi_vip_env", uvm_component parent = null);

    super.new(name, parent);

  endfunction
 
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
 
    slave_agt_cfg_h = axi4_slave_agent_config::type_id::create("slave_agt_cfg_h");

    slave_agt_cfg_h.slave_id           = 0;

    slave_agt_cfg_h.min_address        = 0;

    slave_agt_cfg_h.max_address        = 2**(SLAVE_MEMORY_SIZE) - 1;

    slave_agt_cfg_h.slave_response_mode = RESP_IN_ORDER;

    slave_agt_cfg_h.is_active          = UVM_ACTIVE;  

    slave_agt_cfg_h.has_coverage = 1;

    //slave_agt_cfg_h.read_data_mode   = RANDOM_DATA_MODE;
 
    slave_agt_h = axi4_slave_agent::type_id::create("slave_agt_h", this);

    slave_agt_h.axi4_slave_agent_cfg_h = slave_agt_cfg_h;   

  endfunction
 
 
endclass 
