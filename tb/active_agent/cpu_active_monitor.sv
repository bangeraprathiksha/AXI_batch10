`include "defines.svh"

class cpu_active_monitor extends uvm_monitor;

  `uvm_component_utils(cpu_active_monitor)

  virtual cpu_intf vif;
  cpu_seq_item req;

  uvm_analysis_port #(cpu_seq_item) active_ap;
  uvm_analysis_port #(cpu_seq_item) active_cg_port;

  function new(string name = "cpu_active_monitor", uvm_component parent);
    super.new(name, parent);
    active_ap      = new("active_ap", this);
    active_cg_port = new("active_cg_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual cpu_intf)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Failed to get virtual interface")
  endfunction

  task run_phase(uvm_phase phase);
    cpu_seq_item item;
    forever begin
      @(vif.mon_cb);
      if (vif.wr_en && !vif.full) begin
        item = cpu_seq_item::type_id::create("item");
        item.wr_data = vif.wr_data;
        active_ap.write(item);
      	active_cg_port.write(item);
      end
    end
  endtask

  endtask

endclass
