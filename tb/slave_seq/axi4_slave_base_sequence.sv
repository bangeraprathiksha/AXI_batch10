`ifndef AXI4_SLAVE_BASE_SEQ_INCLUDED_
`define AXI4_SLAVE_BASE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// NOTE: copied verbatim from hvl_top/test/sequences/slave_sequences/axi4_slave_base_seq.sv.
// This project's filelist (sim/cpu_tb.f) does not compile hvl_top/test/* at all (see the
// comment at the top of cpu_tb.f), so the vendor's axi4_slave_seq_pkg (which normally holds
// this file) is never built here. Rather than pulling in that entire package (80+ files,
// many written against the master+slave AVIP flow that this project doesn't use), only the
// 3 files actually needed for a slave write/read responder are copied into tb/slave_seq/.
// Logic is untouched - only this note was added.
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
// Class: axi4_slave_base_seq 
// creating axi4_slave_base_seq class extends from uvm_sequence
//--------------------------------------------------------------------------------------------
class axi4_slave_base_seq extends uvm_sequence #(axi4_slave_tx);
 
  //factory registration
  `uvm_object_utils(axi4_slave_base_seq)

  //-------------------------------------------------------
  // Externally defined Function
  //-------------------------------------------------------
  extern function new(string name = "axi4_slave_base_seq");
endclass : axi4_slave_base_seq

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the axi4_slave_sequence class object
//
// Parameters:
//  name - instance name of the config_template
//-----------------------------------------------------------------------------
function axi4_slave_base_seq::new(string name = "axi4_slave_base_seq");
  super.new(name);
endfunction : new

`endif
