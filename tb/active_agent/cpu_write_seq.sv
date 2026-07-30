class cpu_write_seq extends uvm_sequence #(axi_seq_item);

  `uvm_object_utils(cpu_write_seq)

  axi_seq_item req;

  function new(string name = "cpu_write_seq");
    super.new(name);
  endfunction

  task body();

    req = axi_seq_item::type_id::create("req");

    start_item(req);

    assert(req.randomize() with {
      txn_id inside {[0:15]};
      addr[1:0] == 2'b00;      // Word aligned
      burst inside {0,1,2};    // FIXED, INCR, WRAP
      lock  inside {0,1};
      cache inside {[0:3]};
      prot  inside {[0:7]};
    });

    finish_item(req);

    `uvm_info(get_type_name(), "Generated Write Transaction", UVM_LOW)
    req.print();

  endtask

endclass
