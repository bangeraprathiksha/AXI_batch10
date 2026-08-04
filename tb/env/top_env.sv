//--------------------------------------------------------------------------------------------
// Class: top_env
// NEW FILE. Combines cpu_env (your DUT-side driver/monitor/scoreboard) with
// axi_vip_env (slave VIP only) under one env, plus the virtual sequencer that
// ties cpu_write_seq (and future sequences) to a single run point.
//--------------------------------------------------------------------------------------------
class top_env extends uvm_env;

  `uvm_component_utils(top_env)

  cpu_env  env;
  axi_vip_env  axi_vip_env_h;
  top_vseqr    vseqr_h;

  function new(string name = "top_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env       = cpu_env::type_id::create("env", this);
    axi_vip_env_h = axi_vip_env::type_id::create("axi_vip_env_h", this);
    vseqr_h       = top_vseqr::type_id::create("vseqr_h", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vseqr_h.cpu_sqr_h = env.active_agent.seqr;
    vseqr_h.slave_write_sqr_h = axi_vip_env_h.slave_agt_h.axi4_slave_write_seqr_h;
    vseqr_h.slave_read_sqr_h  = axi_vip_env_h.slave_agt_h.axi4_slave_read_seqr_h;

    axi_vip_env_h.slave_agt_h.axi4_slave_mon_proxy_h.axi4_slave_write_address_analysis_port.connect(env.sb.aw_imp);

    axi_vip_env_h.slave_agt_h.axi4_slave_mon_proxy_h.axi4_slave_write_data_analysis_port.connect(env.sb.w_imp);

    axi_vip_env_h.slave_agt_h.axi4_slave_mon_proxy_h.axi4_slave_write_response_analysis_port.connect(env.sb.b_imp);

    axi_vip_env_h.slave_agt_h.axi4_slave_mon_proxy_h.axi4_slave_read_address_analysis_port.connect(env.sb.ar_imp);

    axi_vip_env_h.slave_agt_h.axi4_slave_mon_proxy_h.axi4_slave_read_data_analysis_port.connect(env.sb.r_imp);

  endfunction

endclass
