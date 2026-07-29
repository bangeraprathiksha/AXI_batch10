// NEW FILE. Filelist for THIS project only - deliberately excludes:
//   - hvl_top/master, hvl_top/env, hvl_top/test, hvl_top/testlists
//     (the vendor's own master+slave AVIP testbench - not used here)
//   - vip/axi_master_vip (no master VIP needed - DUT is the real master)
//   - vip/axi_slave_vip/axi_slave_pkg.sv (the extra, orphaned file with
//     the non-"4" name that references write_fifo_pkg/read_fifo_pkg,
//     which don't exist in this repo - only axi4_slave_pkg.sv is used)
//   - hdl_top/master_agent_bfm/*, hdl_top/master_assertions.sv,
//     hdl_top/tb_master_assertions.sv (master BFM removed from hdl_top.sv)
//
// ASSUMPTION TO VERIFY: slave_assertions.sv / tb_slave_assertions.sv are
// assumed to bind purely against intf + the slave BFM (unaffected by
// removing the master BFM). If they reference master-side BFM signals,
// they'll need adjusting - flagging this rather than guessing further.

// ---- globals ----
globals/axi4_globals_pkg.sv

// ---- HDL interfaces ----
hdl_top/axi4_interface/axi4_if.sv
hdl_top/cpu_inf/interface.sv

// ---- Slave VIP (HVL layer, slave only) - MUST come before the slave BFM
// files below: axi4_slave_driver_bfm.sv/axi4_slave_monitor_bfm.sv both
// `import axi4_slave_pkg::...`, so the package has to be compiled first ----
vip/axi_slave_vip/axi4_slave_pkg.sv

// ---- HDL slave BFM (VIP pin-level layer - unchanged) ----
hdl_top/slave_agent_bfm/axi4_slave_driver_bfm.sv
hdl_top/slave_agent_bfm/axi4_slave_monitor_bfm.sv
hdl_top/slave_agent_bfm/axi4_slave_agent_bfm.sv
hdl_top/slave_assertions.sv
hdl_top/tb_slave_assertions.sv

// ---- HDL top (DUT + cpu_if + intf + slave BFM, no master BFM) ----
hdl_top/hdl_top.sv

// ---- RTL DUT ----
rtl/design_fifo.v
rtl/sync_fifo.v
rtl/decoder.v
rtl/AXI_MASTER_WRITE_CONTROL.v
rtl/AXI_MASTER_READ_CONTROL.v
rtl/write_response_handler.v
rtl/AXI_Master.v
rtl/Top_Module_AXI4.v

// ---- Your testbench ----
tb/tb_pkg.sv

// ---- Top-level ----
tb_top.sv
