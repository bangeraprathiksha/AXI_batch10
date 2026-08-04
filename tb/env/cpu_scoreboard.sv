/*class cpu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(cpu_scoreboard)

  uvm_tlm_analysis_fifo #(cpu_seq_item) cpu_imp;   // from write-fifo monitor
  uvm_tlm_analysis_fifo #(cpu_seq_item) slave_imp;   // from read-fifo monitor

  function new(string name="cpu_scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cpu_imp = new("cpu_imp", this);
    slave_imp = new("slave_imp", this);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      cpu_seq_item wrt,rd;
      wrt = cpu_seq_item::type_id::create("wrt");
      rd  = cpu_seq_item::type_id::create("rd");
      fork
      cpu_imp.get(wrt);
      slave_imp.get(rd);
  join
  end
  endtask

endclass
*/

`uvm_analysis_imp_decl(_cpu)
`uvm_analysis_imp_decl(_slave)

`uvm_analysis_imp_decl(_aw)
`uvm_analysis_imp_decl(_w)
`uvm_analysis_imp_decl(_b)
`uvm_analysis_imp_decl(_ar)
`uvm_analysis_imp_decl(_r)


class cpu_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(cpu_scoreboard)

  uvm_analysis_imp_cpu  #(cpu_seq_item, cpu_scoreboard) cpu_imp;
//   uvm_analysis_imp_slave#(cpu_seq_item, cpu_scoreboard) slave_imp;


uvm_analysis_imp_aw #(axi4_slave_tx,cpu_scoreboard) aw_imp;
uvm_analysis_imp_w #(axi4_slave_tx,cpu_scoreboard) w_imp;
uvm_analysis_imp_b #(axi4_slave_tx,cpu_scoreboard) b_imp;

uvm_analysis_imp_ar #(axi4_slave_tx,cpu_scoreboard) ar_imp;
uvm_analysis_imp_r #(axi4_slave_tx,cpu_scoreboard) r_imp;

  // Reference memory model
//   bit [31:0] memory [bit [31:0]];

  // FIFO Model (Write FIFO)
  bit is_write;
  bit [127:0] fifo_mem [0:4095];
  int wr_ptr;
  int rd_ptr;
  bit empty;
  bit full;
  bit [127:0] rd_data;
  localparam  bit[7:0] SOP = 8'b10101010;
  localparam  bit[7:0] EOP = 8'b01010011;
  bit start_pkt_collect;
  int pkt_start_ptr;

  int pkt_start_q[$];
  int pkt_end_q[$];

  int start_ptr;
  int end_ptr;
  int word_count;
  int beats;

  bit [31:0] wdata_q[$];
  bit [3:0]  wstrb_q[$];
  bit         wlast_seen;

  bit [31:0] rdata_q[$];
  bit         rlast_seen;

  bit [127:0] packet_q[$];

  typedef struct {
    bit [3:0]     txn_id;
    bit [31:0]    addr;
    bit [3:0]     len;
    bit [2:0]     size;
    bit [1:0]     burst;
    bit [1:0]     lock;
    bit [1:0]     cache;
    bit [2:0]     prot;
    bit [3:0]     strobe[];
    bit [31:0]    data[];
  } exp_write_pkt_t;

  typedef struct {
    bit [3:0]     txn_id;
    bit [31:0]    addr;
    bit [3:0]     len;
    bit [2:0]     size;
    bit [1:0]     burst;
    bit [1:0]     lock;
    bit [1:0]     cache;
    bit [2:0]     prot;
    bit [3:0]     strobe[];
    bit [31:0]    data[];
  } exp_read_pkt_t;

  exp_read_pkt_t exp_read_q[$];
  exp_write_pkt_t exp_write_q[$];

    int len;
    int size;
    int data_bytes;
    int actual_bits;
    int expected_words;

axi4_slave_tx aw_q[$];
axi4_slave_tx w_q[$];
axi4_slave_tx ar_q[$];

  function new(string name = "cpu_scoreboard",uvm_component parent);
    super.new(name,parent);
    cpu_imp   = new("cpu_imp",this);
//     slave_imp = new("slave_imp",this);
    aw_imp = new("aw_imp",this);
    w_imp  = new("w_imp",this);
    b_imp  = new("b_imp",this);
    ar_imp = new("ar_imp",this);
    r_imp  = new("r_imp",this);
    wr_ptr = 0;
    rd_ptr = 0;
    start_pkt_collect = 0;
    empty = 1;
    full = 0;

  endfunction


  // AXI Write Address Channel
  function void write_aw(axi4_slave_tx t);
      `uvm_info("SCB",$sformatf("AW Channel Received: ID=%0d ADDR=%h LEN=%0d",t.awid,t.awaddr,t.awlen),UVM_LOW)
      aw_q.push_back(t);
  endfunction

  // AXI Write Data Channel
  function void write_w(axi4_slave_tx t);


   `uvm_info("SCB", $sformatf("W : DATA=%p STRB=%p LAST=%0d",t.wdata, t.wstrb, t.wlast),UVM_LOW)

  foreach (t.wdata[i])
    wdata_q.push_back(t.wdata[i]);

  foreach (t.wstrb[i])
    wstrb_q.push_back(t.wstrb[i]);

    if(t.wlast)
        wlast_seen = 1;

  endfunction

  // AXI Write Response Channel
  function void write_b(axi4_slave_tx t);

    exp_write_pkt_t exp;
    axi4_slave_tx aw;

    `uvm_info("SCB",$sformatf("B : ID=%0d RESP=%0d",t.bid, t.bresp),UVM_LOW);

    //-----------------------------------
    // Expected packet
    //-----------------------------------

    if(exp_write_q.size()==0) begin
        `uvm_error("SCB","No expected write packet")
        return;
    end

    exp = exp_write_q.pop_front();

    //-----------------------------------
    // AW
    //-----------------------------------

    if(aw_q.size()==0) begin
        `uvm_error("SCB","AW missing")
        return;
    end

    aw = aw_q.pop_front();

    //-----------------------------------
    // Header compare
    //-----------------------------------

    if(exp.txn_id != aw.awid)
        `uvm_error("SCB","ID mismatch")

    if(exp.addr != aw.awaddr)
        `uvm_error("SCB","Address mismatch")

    if(exp.len != aw.awlen)
        `uvm_error("SCB","LEN mismatch")

    if(exp.size != aw.awsize)
        `uvm_error("SCB","SIZE mismatch")

    if(exp.burst != aw.awburst)
        `uvm_error("SCB","BURST mismatch")

    if(exp.lock != aw.awlock)
        `uvm_error("SCB","LOCK mismatch")

    if(exp.cache != aw.awcache)
        `uvm_error("SCB","CACHE mismatch")

    if(exp.prot != aw.awprot)
        `uvm_error("SCB","PROT mismatch")

    //-----------------------------------
    // WDATA compare
    //-----------------------------------

    if(wdata_q.size()!=exp.data.size()) begin
      `uvm_error("SCB","Write beat count mismatch")
      wdata_q.delete();
      wstrb_q.delete();
      wlast_seen = 0;
      return;
    end

    foreach(exp.data[i]) begin

        if(exp.data[i]!=wdata_q[i])
          `uvm_error("SCB",$sformatf("DATA mismatch beat %0d",i));

        if(exp.strobe[i]!=wstrb_q[i])
          `uvm_error("SCB",$sformatf("STRB mismatch beat %0d",i));
    end

    //-----------------------------------
    // BRESP
    //-----------------------------------

    if(t.bid!=exp.txn_id)
      `uvm_error("SCB","BID mismatch");

    if(t.bresp!=2'b00)
      `uvm_error("SCB","BRESP Error");

    //-----------------------------------
    // Cleanup
    //-----------------------------------
    wdata_q.delete();
    wstrb_q.delete();
    wlast_seen = 0;

    `uvm_info("SCB","WRITE PASS",UVM_LOW);

  endfunction

  // AXI Read Address Channel
  function void write_ar(axi4_slave_tx t);
    `uvm_info("SCB",$sformatf("AR Channel Received: ID=%0d ADDR=%h LEN=%0d",t.arid,t.araddr,t.arlen),UVM_LOW)
    ar_q.push_back(t);
  endfunction

  // AXI Read Data Channel
  function void write_r(axi4_slave_tx t);

    exp_read_pkt_t exp;
    axi4_slave_tx ar;

`uvm_info("SCB",
          $sformatf("R : ID=%0d DATA=%p RESP=%0d LAST=%0d",
                    t.rid,t.rdata,t.rresp,t.rlast),
          UVM_LOW);

    //---------------------------------------
    // Collect every beat
    //---------------------------------------

    foreach (t.rdata[i])
      rdata_q.push_back(t.rdata[i]);

    if(!t.rlast)
      return;

    //---------------------------------------
    // Expected packet available?
    //---------------------------------------

    if(exp_read_q.size()==0) begin
      `uvm_error("SCB","No expected read packet")
      rdata_q.delete();
      return;
    end

    exp = exp_read_q.pop_front();

    //---------------------------------------
    // AR available?
    //---------------------------------------

    if(ar_q.size()==0) begin
      `uvm_error("SCB","No AR transaction")
      rdata_q.delete();
      return;
    end

    ar = ar_q.pop_front();

    //---------------------------------------
    // Compare AR
    //---------------------------------------

    if(exp.txn_id != ar.arid)
      `uvm_error("SCB","Read ID mismatch");

    if(exp.addr != ar.araddr)
      `uvm_error("SCB","Read Address mismatch");

    if(exp.len != ar.arlen)
      `uvm_error("SCB","Read LEN mismatch");

    if(exp.size != ar.arsize)
      `uvm_error("SCB","Read SIZE mismatch");

    if(exp.burst != ar.arburst)
      `uvm_error("SCB","Read BURST mismatch");

    if(exp.lock != ar.arlock)
      `uvm_error("SCB","Read LOCK mismatch");

    if(exp.cache != ar.arcache)
      `uvm_error("SCB","Read CACHE mismatch");

    if(exp.prot != ar.arprot)
      `uvm_error("SCB","Read PROT mismatch");

    //---------------------------------------
    // Compare Read Data
    //---------------------------------------

    if(rdata_q.size()!=exp.data.size()) begin
      `uvm_error("SCB","Read beat count mismatch")
      rdata_q.delete();
      rlast_seen = 0;
      return;
    end

    foreach(exp.data[i]) begin

      if(exp.data[i] != rdata_q[i])
          `uvm_error("SCB",$sformatf("Read DATA mismatch beat %0d",i));

    end

    //---------------------------------------
    // Compare RRESP
    //---------------------------------------

    if(exp.txn_id != t.rid)
      `uvm_error("SCB","RID mismatch");

    if(t.rresp != 2'b00)
      `uvm_error("SCB","Read Response Error");

    //---------------------------------------
    // Cleanup
    //---------------------------------------

    rdata_q.delete();

    `uvm_info("SCB","READ TRANSACTION PASSED",UVM_LOW);

  endfunction

  function void write_cpu(cpu_seq_item t);

    if(!t.wr_en)
      return;

    //-----------------------------
    // FIFO Full
    //-----------------------------
    if(full) begin
      `uvm_error("SCB","FIFO Full")
      return;
    end

    //-----------------------------
    // Unexpected SOP
    //-----------------------------
    if(start_pkt_collect && (t.wr_data[127:120] == SOP)) begin
        `uvm_error("SCB","Received SOP before previous packet completed")
        return;
    end

    //-----------------------------
    // First word
    //-----------------------------
    if(!start_pkt_collect && (t.wr_data[127:120] == SOP)) begin

      start_pkt_collect = 1;
      pkt_start_ptr = wr_ptr;
      len = t.wr_data[83:80];

                                                   
      beats = len + 1;
      actual_bits = 60 + beats*4 + beats*32 + 8;
      expected_words = (actual_bits + 127)/128;
      word_count = 0;
    end

    //-----------------------------
    // Packet must start with SOP
    //-----------------------------
    if(!start_pkt_collect) begin
        `uvm_error("SCB","Packet without SOP")
        return;
    end

    //-----------------------------
    // Store word
    //-----------------------------
    fifo_mem[wr_ptr] = t.wr_data;

    wr_ptr++;
    word_count++;

    //-----------------------------
    // Packet Complete
    //-----------------------------
    if(word_count == expected_words) begin
      start_pkt_collect = 0;
      pkt_start_q.push_back(pkt_start_ptr);
      pkt_end_q.push_back(wr_ptr-1);
      expected_words = 0;
      word_count = 0;
    end

    //-----------------------------
    // FIFO Status
    //-----------------------------
    empty = (wr_ptr == rd_ptr);
    full  = ((wr_ptr-rd_ptr) >= 4096);
  endfunction
  task fifo_read(input int start_ptr, input int end_ptr);
    int ptr;
    ptr = start_ptr;
    while (ptr <= end_ptr) begin
        rd_data = fifo_mem[ptr];
        decoder(rd_data);
        ptr++;
    end
    rd_ptr = end_ptr + 1;
    empty = (wr_ptr == rd_ptr);
    full  = ((wr_ptr - rd_ptr) >= 4096);
  endtask


  task decoder(bit [127:0] fifo_word);

    // First word
    if (fifo_word[127:120] == SOP) begin
        len   = fifo_word[83:80];
        beats = len + 1;
        actual_bits    = 60 + (beats*4) + (beats*32) + 8;
        expected_words = (actual_bits + 127) / 128;

    end

        // Store every FIFO word
        packet_q.push_back(fifo_word);

        // Wait until complete packet
    if(packet_q.size() == expected_words) begin
        decode_packet(packet_q);
        packet_q.delete();
        expected_words = 0;
        end
  endtask

  task decode_packet(bit [127:0] packet_q[$]);
    bit packet[];

        bit [127:0] hdr;

        bit [7:0]  sop;
        bit [3:0]  txn_id;
        bit [31:0] addr;
        bit [3:0]  len;
        bit [2:0]  size;
        bit [1:0]  burst;
        bit [1:0]  lock;
        bit [1:0]  cache;
        bit [2:0]  prot;
    bit [3:0]  strobe[];
    bit [31:0]  data[];
    bit [7:0]  eop;

    int idx = 0;
    int ptr_data;
    int ptr_eop;
    int beats;
    int ptr_strobe;
    int total_bits;

    exp_write_pkt_t write_pkt;
    exp_read_pkt_t read_pkt;

    if(packet_q.size() == 0) begin
        `uvm_error("SCB","Empty packet")
        return;
        end

        hdr = packet_q[0];

    sop    = hdr[127:120];
    txn_id = hdr[119:116];
    addr   = hdr[115:84];
    len    = hdr[83:80];
    size   = hdr[79:77];
    burst  = hdr[76:75];
        lock   = hdr[74:73];
        cache  = hdr[72:71];
        prot   = hdr[70:68];

    if(sop != SOP)
      `uvm_error("SCB","SOP mismatch")

    // Calculate variable sizes
    beats = len+1;
    total_bits = packet_q.size()*128;

    // Converting entire packet into bit array
    packet = new[total_bits];

    foreach(packet_q[i]) begin
      for(int j=127;j>=0;j--)
        packet[idx++] = packet_q[i][j];
    end

    //for strobe
    ptr_strobe = 60;
    strobe = new[beats];
    for (int i = 0; i < beats; i++)begin
      for(int j=3; j>=0; j--)begin
        strobe[i][j] = packet[ptr_strobe++];
      end
    end

    //for data
    ptr_data = 60 + (beats*4);
    data = new[beats];

    for (int i = 0; i < beats; i++) begin
      for (int j = 31; j >= 0; j--) begin
        data[i][j] = packet[ptr_data++];
      end
    end

    //for eop
    ptr_eop = 60 + (beats*4) + (beats*32);

    for (int i = 7; i >= 0; i--)begin
      eop[i] = packet[ptr_eop++];
    end

    if (eop != EOP)
      `uvm_error("SCB", "EOP mismatch")

    if((beats == 1) && (data[0] ==  32'h00000000))begin
        read_pkt.txn_id = txn_id;
                read_pkt.addr   = addr;
                read_pkt.len    = len;
                read_pkt.size   = size;
                read_pkt.burst  = burst;
                read_pkt.lock   = lock;
                read_pkt.cache  = cache;
                read_pkt.prot   = prot;
                read_pkt.strobe = strobe;
                read_pkt.data   = data;
        exp_read_q.push_back(read_pkt);
    end
    else begin
        write_pkt.txn_id = txn_id;
                write_pkt.addr   = addr;
                write_pkt.len    = len;
                write_pkt.size   = size;
                write_pkt.burst  = burst;
                write_pkt.lock   = lock;
                write_pkt.cache  = cache;
                write_pkt.prot   = prot;
                write_pkt.strobe = strobe;
                write_pkt.data   = data;
        exp_write_q.push_back(write_pkt);
    end

  endtask

  task run_phase(uvm_phase phase);

    forever begin
        // Wait until complete packet is available
        wait(pkt_start_q.size() > 0 && pkt_end_q.size() > 0);

        start_ptr = pkt_start_q.pop_front();
        end_ptr   = pkt_end_q.pop_front();

        `uvm_info("SCB",$sformatf("Packet Received : Start=%0d End=%0d",start_ptr,end_ptr),UVM_LOW)

         fifo_read(start_ptr,end_ptr);//collecting complete packet
    end

  endtask

endclass
