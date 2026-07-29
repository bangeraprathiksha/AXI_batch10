//--------------------------------------------------------------------------------------------
// Package: cpu_tb_pkg
// NEW FILE. Bundles every tb/ class into one package, in dependency order,
// matching the vendor's own axi4_master_pkg.sv / axi4_slave_pkg.sv convention.
// Needs axi4_globals_pkg and axi4_slave_pkg compiled/imported before this.
//--------------------------------------------------------------------------------------------
package cpu_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_globals_pkg::*;
  import axi4_slave_pkg::*;

  // ADDED: axi4_slave_write_seq/axi4_slave_read_seq (copied into tb/slave_seq -
  // see the note at the top of tb/slave_seq/axi4_slave_base_seq.sv for why).
  // Only need axi4_slave_tx/axi4_slave_pkg types, both already imported above.
  `include "slave_seq/axi4_slave_base_seq.sv"
  `include "slave_seq/axi4_slave_write_seq.sv"
  `include "slave_seq/axi4_slave_read_seq.sv"

  `include "active_agent/cpu_seq_item.sv"
  `include "active_agent/axi_seq_item.sv"
  `include "active_agent/cpu_sequencer.sv"
  `include "active_agent/cpu_driver.sv"
  `include "active_agent/cpu_active_monitor.sv"
  `include "active_agent/cpu_active_agent.sv"
  `include "active_agent/write_seq.sv"
  `include "active_agent/read_seq.sv"   // ADDED: cpu-side read sequence

  `include "passive_agent/cpu_passive_monitor.sv"
  `include "passive_agent/cpu_passive_agent.sv"

  `include "env/cpu_scoreboard.sv"
  `include "env/cpu_subscriber.sv"
  `include "env/cpu_env.sv"
  `include "env/axi4_vip_env.sv"

  `include "vseq/top_vseq.sv"
  // ADDED: the 2 virtual sequences that run the cpu sequence and the AXI4
  // slave sequence together (see each file's header comment for why).
  `include "vseq/axi4_virtual_write_seq.sv"
  `include "vseq/axi4_virtual_read_seq.sv"

  `include "env/top_env.sv"
  `include "test/base_test.sv"
  `include "test/single_seq_test.sv"
  // ADDED: the 2 requested virtual testcases.
  `include "test/axi4_virtual_write_test.sv"
  `include "test/axi4_virtual_read_test.sv"

endpackage : cpu_tb_pkg
