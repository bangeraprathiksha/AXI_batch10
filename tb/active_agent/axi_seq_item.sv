class axi_seq_item extends uvm_sequence_item;

  rand bit [3:0]  txn_id;
  rand bit [31:0] addr;
  rand bit [3:0]  len;
  rand bit [2:0]  size;
  rand bit [1:0]  burst;
  rand bit [1:0]  lock;
  rand bit [1:0]  cache;
  rand bit [2:0]  prot;
  rand bit [3:0]  strobe[];
  rand bit [31:0]  data[];

  `uvm_object_utils(axi_seq_item)

  function new(string name="axi_seq_item");
    super.new(name);
  endfunction

  constraint c_len {
    len == 0;
  }

  constraint c_size {
    size == 2;
  }

//   constraint c_arrays {
//     data.size()   == ((len+1) * (1<<size));
//     strobe.size() == ((len+1) * (1<<size));
//   }
  
  
  constraint c_arrays {
    data.size()   == len+1;
    strobe.size() == len+1;
  }

  constraint c_strobe {
    foreach(strobe[i])
      strobe[i] == 4'hF;
  }
  
  constraint c_solve_order {
  	solve len before data;
  	solve len before strobe;
  }
  
  
endclass
