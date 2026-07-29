`include "defines.svh"

class cpu_passive_monitor extends uvm_monitor;

  `uvm_component_utils(cpu_passive_monitor)

  virtual cpu_intf vif;
  cpu_seq_item item;

  uvm_analysis_port #(cpu_seq_item) passive_ap;
  uvm_analysis_port #(cpu_seq_item) passive_cg_port;

  function new(string name = "cpu_passive_monitor", uvm_component parent);
    super.new(name, parent);
    passive_ap      = new("passive_ap", this);
    passive_cg_port = new("passive_cg_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual cpu_intf)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Failed to get virtual interface")
  endfunction

  task run_phase(uvm_phase phase);

    forever begin
      @(vif.mon_cb);
      if (vif.rd_en && !vif.empty) begin
        item = cpu_seq_item::type_id::create("item");
        item.rd_data = vif.rd_data;
        passive_ap.write(item);
        passive_cg_port.write(item);
      end
    end
  endtask

endclass
