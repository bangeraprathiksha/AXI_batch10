`ifndef TB_TOP_INCLUDED_
`define TB_TOP_INCLUDED_

//--------------------------------------------------------------------------------------------
// Module: tb_top
// NEW FILE. This replaces hvl_top.sv as the simulation entry point for THIS
// project - hvl_top.sv is untouched and still runs the vendor's own
// axi4_base_test if you compile it instead, but it is NOT part of this
// project's filelist (see sim/cpu_tb.f), so there is no conflict between the
// two run_test() calls.
//--------------------------------------------------------------------------------------------
module tb_top;

  import uvm_pkg::*;
  import axi4_globals_pkg::*;
  import axi4_slave_pkg::*;
  import tb_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    run_test("base_test");
  end

endmodule : tb_top

`endif
