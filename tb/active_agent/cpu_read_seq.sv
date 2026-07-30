class cpu_read_seq extends uvm_sequence #(axi_seq_item);

  `uvm_object_utils(cpu_read_seq)

  axi_seq_item req;

  function new(string name = "cpu_read_seq");
    super.new(name);
  endfunction

  task body();

    req = axi_seq_item::type_id::create("req");

    start_item(req);

    assert(req.randomize() with {
      txn_id inside {[0:15]};
      addr[1:0] == 2'b00;      // Word aligned
      burst inside {0,1,2};
      lock  inside {0,1};
      cache inside {[0:3]};
      prot  inside {[0:7]};

      // Read packet contains only one DATA byte = 0
      data.size() == 1;
      data[0] == 32'h00000000;

      strobe.size() == 1;
      strobe[0] == 4'h0;
    });

    finish_item(req);
      `uvm_info(get_type_name(),
    $sformatf("Generated Read Transaction:\nTXN_ID = %0d\nADDR = 0x%08h\nLEN = %0d\nSIZE = %0d\nBURST = %0d\nLOCK = %0d\nCACHE = %0d\nPROT = %0d\nSTROBE = 0x%0h\nDATA = 0x%08h",
              req.txn_id,
              req.addr,
              req.len,
              req.size,
              req.burst,
              req.lock,
              req.cache,
              req.prot,
              req.strobe[0],
              req.data[0]),
    UVM_LOW)
    `uvm_info(get_type_name(), "Generated Read Transaction", UVM_LOW)
    req.print();

  endtask

endclass
