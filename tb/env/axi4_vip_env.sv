//--------------------------------------------------------------------------------------------
// Class: axi_vip_env
// NEW FILE. Thin wrapper around ONLY axi4_slave_agent from the vendor's
// axi4_slave_pkg - per your instruction to use the slave VIP only (no master
// agent instantiated, since Top_Module_AXI4 is now the real AXI4 master).
//
// axi4_slave_agent_bfm (in hdl_top.sv) already publishes its virtual interface
// via config_db globally ("*"), so axi4_slave_driver_proxy/monitor_proxy inside
// axi4_slave_agent find it automatically - no extra config_db wiring needed here.
//
// NOTE on config timing: axi4_slave_agent's OWN build_phase constructs a fresh
// default axi4_slave_agent_cfg_h (is_active defaults to UVM_ACTIVE already, which
// is what we want). min_address/max_address/response mode are only consumed at
// RUN time by the driver proxy, so it's safe to set them here in
// end_of_elaboration_phase (after the whole tree has built) by reaching directly
// into slave_agt_h.axi4_slave_agent_cfg_h - these are handle/reference fields,
// so setting them here is visible everywhere that already holds that handle.
//--------------------------------------------------------------------------------------------
class axi_vip_env extends uvm_env;

  `uvm_component_utils(axi_vip_env)

  axi4_slave_agent slave_agt_h;

  function new(string name = "axi_vip_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    slave_agt_h = axi4_slave_agent::type_id::create("slave_agt_h", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    slave_agt_h.axi4_slave_agent_cfg_h.slave_id           = 0;
    slave_agt_h.axi4_slave_agent_cfg_h.min_address         = 0;
    slave_agt_h.axi4_slave_agent_cfg_h.max_address         = 2**(SLAVE_MEMORY_SIZE) - 1;
    slave_agt_h.axi4_slave_agent_cfg_h.slave_response_mode = RESP_IN_ORDER;
    slave_agt_h.axi4_slave_agent_cfg_h.read_data_mode      = RANDOM_DATA_MODE;
  endfunction

endclass
