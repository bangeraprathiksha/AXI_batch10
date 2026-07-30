class cpu_read_seq extends uvm_sequence #(axi_seq_item);

  `uvm_object_utils(cpu_read_seq)

  axi_seq_item req;

  function new(string name = "cpu_read_seq");
    super.new(name);
  endfunction

  task body();

    req = axi_seq_item::type_id::create("req");

    start_item(req);

    if (!req.randomize() with {
      txn_id inside {[0:15]};
      addr[1:0] == 2'b00;
      burst inside {0,1,2};
      lock  inside {0,1};
      cache inside {[0:3]};
      prot  inside {[0:7]};

      data.size() == 1;
      data[0] == 32'h00000000;

      strobe.size() == 1;
      strobe[0] == 4'h0;
    })
      `uvm_fatal(get_type_name(), "Randomization Failed")

    finish_item(req);

    `uvm_info(get_type_name(),
      $sformatf(
      "\n=====================================================\n\
       GENERATED READ TRANSACTION\n\
       -----------------------------------------------------\n\
       TIME    : %0t\n\
       TXN_ID  : %0d\n\
       ADDR    : 0x%08h\n\
       LEN     : %0d\n\
       SIZE    : %0d\n\
       BURST   : %0d\n\
       LOCK    : %0d\n\
       CACHE   : %0d\n\
       PROT    : %0d\n\
       STROBE  : 0x%0h\n\
       DATA    : 0x%08h\n\
       =====================================================",
      $time,
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

    req.print();

  endtask

endclass
