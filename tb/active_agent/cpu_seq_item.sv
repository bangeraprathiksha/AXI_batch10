class cpu_seq_item extends uvm_sequence_item;
  
  logic rst;
  logic full;
  logic empty;
  logic [127:0] rd_data;
  
  rand logic wr_en;
  rand logic rd_en;
  rand logic [127:0] wr_data;
  
  `uvm_object_utils_begin(cpu_seq_item)
   `uvm_field_int(full,UVM_ALL_ON)
   `uvm_field_int(empty,UVM_ALL_ON)
   `uvm_field_int(rd_data,UVM_ALL_ON)
   `uvm_field_int(wr_en,UVM_ALL_ON)
   `uvm_field_int(rd_en,UVM_ALL_ON)
   `uvm_field_int(wr_data,UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "cpu_seq_item");
    super.new(name);
  endfunction
  constraint c1{ wr_en ==1 ;}
endclass
  
  
  
