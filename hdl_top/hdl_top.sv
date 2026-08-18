`ifndef HDL_TOP_INCLUDED_
`define HDL_TOP_INCLUDED_

//--------------------------------------------------------------------------------------------
// Module      : HDL Top
// Description : Has a interface master and slave agent bfm.
//--------------------------------------------------------------------------------------------

module hdl_top;

  import uvm_pkg::*;
  import axi4_globals_pkg::*;
  `include "uvm_macros.svh"

  //-------------------------------------------------------
  // Clock Reset Initialization
  //-------------------------------------------------------
  bit aclk;
  bit aresetn;

  //-------------------------------------------------------
  // System Clock Generation
  //-------------------------------------------------------
  initial begin
    aclk = 1'b0;
    forever #10 aclk = ~aclk;
  end

  //-------------------------------------------------------
  // System Reset Generation
  // Active low reset
  //-------------------------------------------------------
  initial begin
    aresetn = 1'b1;
    #10 aresetn = 1'b0;

    repeat (1) begin
      @(posedge aclk);
    end
    aresetn = 1'b1;
  end
  
  initial begin
    $dumpfile("waveform.vcd");      // name of the VCD file
    $dumpvars(0, hdl_top);    // dump variables from the testbench top
  end

cpu_intf c_intf(.clk(aclk),.rst(aresetn));


  // Variable : intf
  // axi4 Interface Instantiation
  axi4_if intf(.aclk(aclk),
               .aresetn(aresetn));


initial begin
    uvm_config_db#(virtual cpu_intf)::set(null,"*","vif",c_intf);
  end               
  //-------------------------------------------------------
  // AXI4  No of Master and Slaves Agent Instantiation
  //-------------------------------------------------------
  genvar i;
  generate
/*  
  for (i=0; i<NO_OF_MASTERS; i++) begin : axi4_master_agent_bfm
      axi4_master_agent_bfm #(.MASTER_ID(i)) axi4_master_agent_bfm_h(intf);
      defparam axi4_master_agent_bfm[i].axi4_master_agent_bfm_h.MASTER_ID = i;
    end
*/
    for (i=0; i<NO_OF_SLAVES; i++) begin : axi4_slave_agent_bfm
      axi4_slave_agent_bfm #(.SLAVE_ID(i)) axi4_slave_agent_bfm_h(intf);
      defparam axi4_slave_agent_bfm[i].axi4_slave_agent_bfm_h.SLAVE_ID = i;
    end
  endgenerate

 Top_Module_AXI4 dut (
    .clk      (aclk),
    .rstn     (aresetn),
    .ACLK     (aclk),
    .ARESETn  (aresetn),

    // FIFO side -> cpu_if
    .wr_en    (c_intf.wr_en),
    .rd_en    (c_intf.rd_en),
    .wr_data  (c_intf.wr_data),
    .rd_data  (c_intf.rd_data),
    .full     (c_intf.full),
    .empty    (c_intf.empty),

    // AXI side -> intf (write address channel)
    .AWID_a    (intf.awid),
    .AWADDR_a  (intf.awaddr),
    .AWLEN_a   (intf.awlen),
    .AWSIZE_a  (intf.awsize),
    .AWBURST_a (intf.awburst),
    .AWLOCK_a  (intf.awlock),
    .AWCACHE_a (intf.awcache),
    .AWPROT_a  (intf.awprot),
    .AWVALID_a (intf.awvalid),
    .AWREADY_a (intf.awready),

    // AXI side -> intf (write data channel) - WID_a left unconnected,
    // axi4_if has no wid signal (AXI4 dropped per-beat WID vs AXI3)
    .WDATA_a  (intf.wdata),
    .WSTRB_a  (intf.wstrb),
    .WLAST_a  (intf.wlast),
    .WVALID_a (intf.wvalid),
    .WREADY_a (intf.wready),

    // AXI side -> intf (write response channel)
    .BID_a    (intf.bid),
    .BRESP_a  (intf.bresp),
    .BVALID_a (intf.bvalid),
    .BREADY_a (intf.bready),

    // AXI side -> intf (read address channel)
    .ARID_a    (intf.arid),
    .ARADDR_a  (intf.araddr),
    .ARLEN_a   (intf.arlen),
    .ARSIZE_a  (intf.arsize),
    .ARBURST_a (intf.arburst),
    .ARLOCK_a  (intf.arlock),
    .ARCACHE_a (intf.arcache),
    .ARPROT_a  (intf.arprot),
    .ARVALID_a (intf.arvalid),
    .ARREADY_a (intf.arready),

    // AXI side -> intf (read data channel)
    .RID_a    (intf.rid),
    .RDATA_a  (intf.rdata),
    .RRESP_a  (intf.rresp),
    .RLAST_a  (intf.rlast),
    .RVALID_a (intf.rvalid),
    .RREADY_a (intf.rready)
  );  
  
endmodule : hdl_top

`endif

