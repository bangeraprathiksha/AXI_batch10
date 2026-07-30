

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
    send_packet(req);
    seq_item_port.item_done();
  end
endtask

task read_process();
  forever begin
    @(posedge vif.clk);
    if (!vif.empty)
      vif.rd_en <= 1'b1;
    else
      vif.rd_en <= 1'b0;
  end
endtask

  task send_packet(axi_seq_item pkt);
    bit packet_bits[$];
    bit [127:0] word;
    int idx;
    int total_bits;
    int pad_bits;

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

    foreach (pkt.strobe[i])begin
     for(int j=3;j>=0;j--)
       packet_bits.push_back(pkt.strobe[i][j]);
    end

    foreach (pkt.data[i])begin
        for (int j = 31; j >= 0; j--)
        packet_bits.push_back(pkt.data[i][j]);
    end

    for (int i = 7; i >= 0; i--)
      packet_bits.push_back(EOP[i]);

    total_bits = packet_bits.size();
    pad_bits   = (128 - (total_bits % 128)) % 128;

    if (pad_bits != 0) begin
      `uvm_info("DRV", $sformatf("Packet needs %0d padding bits to fill last word", pad_bits), UVM_MEDIUM)
      repeat (pad_bits)
        packet_bits.push_back(1'b0);
    end

    idx = 0;
    while (idx < packet_bits.size()) begin
      word = '0;
      for (int b = 127; b >= 0; b--)
        word[b] = packet_bits[idx++];

      @(posedge vif.clk);
      while (vif.full)
        @(posedge vif.clk);

      vif.wr_data <= word;
      vif.wr_en   <= 1'b1;
      vif.rd_en   <= 1'b0;
    end

    @(posedge vif.clk);
    vif.wr_en <= 1'b0;
  endtask

endclass

 
