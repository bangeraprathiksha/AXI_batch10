class cpu_env extends uvm_env;

  `uvm_component_utils(cpu_env)

  cpu_active_agent   active_agent;
  cpu_passive_agent  passive_agent;
  cpu_scoreboard     sb;
  cpu_subscriber     cov;

  function new(string name="cpu_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    active_agent  = cpu_active_agent ::type_id::create("active_agent", this);
    passive_agent = cpu_passive_agent::type_id::create("passive_agent", this);
    sb            = cpu_scoreboard   ::type_id::create("sb", this);
    cov           = cpu_subscriber   ::type_id::create("cov", this);
  endfunction


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //---------------------------------------
    // CPU monitor -> Scoreboard
    //---------------------------------------
    active_agent.mon.active_ap.connect(sb.cpu_imp.analysis_export);
    passive_agent.mon.passive_ap.connect(sb.slave_imp.analysis_export);
    // active_agent.mon.active_ap.connect(sb.cpu_imp);
    // passive_agent.mon.passive_ap.connect(sb.slave_imp);

    //---------------------------------------
    // Coverage
    //---------------------------------------
    active_agent.mon.active_cg_port.connect(cov.active_mon_cov_imp);
    passive_agent.mon.passive_cg_port.connect(cov.passive_mon_cov_imp);


  endfunction

endclass
