`include "defines.svh"

class cpu_driver extends uvm_driver #(axi_seq_item);

  `uvm_component_utils(cpu_driver)

  virtual cpu_intf vif;

  localparam bit [7:0] SOP = 8'hAA;
  localparam bit [7:0] EOP = 8'h53;

  function new(string name = "cpu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual cpu_intf)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Cannot get virtual interface");
  endfunction


  task run_phase(uvm_phase phase);
    fork
      write_process();
      read_process();
    join
  endtask


  task write_process();
    axi_seq_item req;
    forever begin
      seq_item_port.get_next_item(req);

      `uvm_info(get_type_name(),$sformatf("[%0t] Received transaction from Sequencer",$time),UVM_LOW)

      req.print();

      send_packet(req);

      `uvm_info(get_type_name(),$sformatf("Packet transmission completed",$time),UVM_LOW)
      
      seq_item_port.item_done();
    end
  endtask


  task read_process();
    forever begin
      @(posedge vif.clk);
      if (!vif.empty) begin
        vif.rd_en <= 1'b1;
        `uvm_info(get_type_name(),$sformatf("[%0t] FIFO NOT EMPTY -> rd_en asserted",$time),UVM_HIGH)
      end
      else begin
        vif.rd_en <= 1'b0;
        `uvm_info(get_type_name(),$sformatf("[%0t] FIFO EMPTY -> rd_en deasserted",$time),UVM_HIGH)
      end
    end
  endtask


  task send_packet(axi_seq_item pkt);
    bit packet_bits[$];
    bit [127:0] word;
    int idx;
    int total_bits;
    int pad_bits;

    `uvm_info(get_type_name(),
              $sformatf("\n
================ DRIVER WRITE TRANSACTION ================\n\
TXN_ID : %0h\n\
ADDR   : %08h\n\
LEN    : %0d\n\
SIZE   : %0d\n\
BURST  : %0d\n\
LOCK   : %0d\n\
CACHE  : %0d\n\
PROT   : %0d",
      pkt.txn_id,
      pkt.addr,
      pkt.len,
      pkt.size,
      pkt.burst,
      pkt.lock,
      pkt.cache,
      pkt.prot),
      UVM_LOW)

    foreach(pkt.strobe[i])
      `uvm_info(get_type_name(),
        $sformatf("STROBE[%0d] = %h", i, pkt.strobe[i]),
        UVM_LOW)

    foreach(pkt.data[i])
      `uvm_info(get_type_name(),
        $sformatf("DATA[%0d] = %08h", i, pkt.data[i]),
        UVM_LOW)

    for (int i = 7; i >= 0; i--)
      packet_bits.push_back(SOP[i]);

    for (int i = 3; i >= 0; i--)
      packet_bits.push_back(pkt.txn_id[i]);

    for (int i = 31; i >= 0; i--)
      packet_bits.push_back(pkt.addr[i]);

    for (int i = 3; i >= 0; i--)
      packet_bits.push_back(pkt.len[i]);

    for (int i = 2; i >= 0; i--)
      packet_bits.push_back(pkt.size[i]);

    for (int i = 1; i >= 0; i--)
      packet_bits.push_back(pkt.burst[i]);

    for (int i = 1; i >= 0; i--)
      packet_bits.push_back(pkt.lock[i]);

    for (int i = 1; i >= 0; i--)
      packet_bits.push_back(pkt.cache[i]);

    for (int i = 2; i >= 0; i--)
      packet_bits.push_back(pkt.prot[i]);

    foreach (pkt.strobe[i]) begin
      for (int j = 3; j >= 0; j--)
        packet_bits.push_back(pkt.strobe[i][j]);
    end

    foreach (pkt.data[i]) begin
      for (int j = 31; j >= 0; j--)
        packet_bits.push_back(pkt.data[i][j]);
    end

    for (int i = 7; i >= 0; i--)
      packet_bits.push_back(EOP[i]);

    total_bits = packet_bits.size();

    `uvm_info(get_type_name(),
              $sformatf("[%0t] Packet size before padding = %0d bits",$time, total_bits),
      UVM_LOW)

    pad_bits = (128 - (total_bits % 128)) % 128;

    if (pad_bits != 0) begin
      repeat (pad_bits)
        packet_bits.push_back(1'b0);
    end

    `uvm_info(get_type_name(),
              $sformatf("Packet size after padding = %0d bits\n packets = %p", packet_bits.size(),packet_bits),
      UVM_LOW)

    idx = 0;

    while (idx < packet_bits.size()) begin

      word = '0;

      for (int b = 127; b >= 0; b--)
        word[b] = packet_bits[idx++];

      `uvm_info(get_type_name(),
          $sformatf("[%0t] Prepared 128-bit FIFO Word = %032h",
                    $time,
                    word),
          UVM_LOW)

      @(posedge vif.clk);

      while (vif.full) begin
        `uvm_info(get_type_name(),
          "FIFO FULL...Waiting",
          UVM_MEDIUM)
        @(posedge vif.clk);
      end

      vif.wr_data <= word;
      vif.wr_en   <= 1'b1;
      vif.rd_en   <= 1'b0;

      `uvm_info(get_type_name(),
                $sformatf("[%0t] Driven wr_data = %032h, wr_en = %0b", $time,word, 1'b1),
        UVM_LOW)
    end

    @(posedge vif.clk);

    vif.wr_en <= 1'b0;

    `uvm_info(get_type_name(),
      "wr_en deasserted. Packet transmission finished.",
      UVM_LOW)

  endtask

endclass
