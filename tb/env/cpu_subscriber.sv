`uvm_analysis_imp_decl(_active_mon_cg)
`uvm_analysis_imp_decl(_passive_mon_cg)

class cpu_subscriber extends uvm_component;

  `uvm_component_utils(cpu_subscriber)

  uvm_analysis_imp_active_mon_cg #(cpu_seq_item, cpu_subscriber) active_mon_cov_imp;
  uvm_analysis_imp_passive_mon_cg #(cpu_seq_item, cpu_subscriber) passive_mon_cov_imp;

  cpu_seq_item active;
  cpu_seq_item passive;

  covergroup active_mon_cg;
    rst_cp : coverpoint active.rst {
      bins rst_low  = {0};
      bins rst_high = {1};
    }
    wr_en_cp : coverpoint active.wr_en {
      bins low  = {0};
      bins high = {1};
    }
    rd_en_cp : coverpoint active.rd_en {
      bins low  = {0};
      bins high = {1};
    }
    wr_data_cp : coverpoint active.wr_data {
      bins low    = {[128'h00000000000000000000000000000000 : 128'h0000000000000000FFFFFFFFFFFFFFFF]};
      bins medium = {[128'h00000000000000010000000000000000 : 128'h1111111111111111FFFFFFFFFFFFFFFF]};
      bins high   = {[128'h11111111111111120000000000000000 : 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF]};
    }
  endgroup

  covergroup passive_mon_cg;
    full_cp : coverpoint passive.full {
      bins low  = {0};
      bins high = {1};
    }
    empty_cp : coverpoint passive.empty {
      bins low  = {0};
      bins high = {1};
    }
    rd_data_cp : coverpoint passive.rd_data {
      bins low = {[128'h00000000000000000000000000000000 : 128'h0000000000000000FFFFFFFFFFFFFFFF]};
      bins medium = {[128'h00000000000000010000000000000000 : 128'h1111111111111111FFFFFFFFFFFFFFFF]};
      bins high = {[128'h11111111111111120000000000000000 : 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF]};
    }
  endgroup

  function new(string name = "cpu_subscriber",uvm_component parent);
    super.new(name,parent);
    active_mon_cov_imp  = new("active_mon_cov_imp", this);
    passive_mon_cov_imp = new("passive_mon_cov_imp", this);
    active_mon_cg  = new();
    passive_mon_cg = new();
  endfunction

  function void write_active_mon_cg(cpu_seq_item req);
    active = cpu_seq_item::type_id::create("active");
    active_mon_cg.sample();
  endfunction

  function void write_passive_mon_cg(cpu_seq_item req);
    passive = cpu_seq_item::type_id::create("passive");
    passive_mon_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("\n=================================================");
    $display("            ACTIVE MONITOR COVERAGE");
    $display("=================================================");
    $display("Coverage = %0.2f%%", active_mon_cg.get_coverage());

    $display("\n=================================================");
    $display("           PASSIVE MONITOR COVERAGE");
    $display("=================================================");
    $display("Coverage = %0.2f%%", passive_mon_cg.get_coverage());
  endfunction

endclass
