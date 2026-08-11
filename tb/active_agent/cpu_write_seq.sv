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
      burst == 2'b1;    // FIXED
      lock  inside {0,1};
      cache inside {[0:3]};
      prot  inside {[0:7]};
    });

    finish_item(req);

    `uvm_info(get_type_name(), "Generated Write Transaction", UVM_LOW)
    `uvm_info(get_type_name(),$sformatf("\n\
                ================ WRITE TRANSACTION ================\n\
                TXN_ID : %0h\n\
                ADDR   : %08h\n\
                LEN    : %0d\n\
                SIZE   : %0d\n\
                BURST  : %0d\n\
                LOCK   : %0d\n\
                CACHE  : %0d\n\
                PROT   : %0d",
                req.txn_id,
                req.addr,
                req.len,
                req.size,
                req.burst,
                req.lock,
                req.cache,
                req.prot),
                UVM_LOW)

    foreach(req.strobe[i])
      `uvm_info(get_type_name(),
        $sformatf("STROBE[%0d] = %h", i, req.strobe[i]),
        UVM_LOW)

    foreach(req.data[i])
      `uvm_info(get_type_name(),
        $sformatf("DATA[%0d]   = %08h", i, req.data[i]),
        UVM_LOW)

    req.print();

  endtask

endclass
