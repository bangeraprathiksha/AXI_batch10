//--------------------------------------------------------------------------------------------
// Class: axi4_virtual_write_seq
// NEW FILE. This is the actual "virtual sequence" the project was missing:
// top_vseq (in top_vseq.sv) only ever drove cpu_write_seq on the cpu
// sequencer - the AXI4 slave VIP sequencer was never given anything to run,
// so it just sat idle behind whatever default response behavior the driver
// proxy falls back to.
//
// Here we run TWO sequences at the same time, in the same virtual sequence,
// each on its own sequencer:
//   - cpu_write_seq       -> cpu_sqr_h              (drives the CPU write side)
//   - axi4_slave_write_seq -> slave_write_sqr_h      (drives the AXI4 slave VIP
//                                                      write response side)
//
// The slave side is a "responder": Top_Module_AXI4 (the real AXI4 master
// inside the DUT) only issues a write burst on the AXI4 bus some time after
// the CPU has pushed data into the write FIFO, and we don't know exactly
// when that burst will land. So the slave_write_seq is run in a forever
// loop in the background (fork), while the cpu_write_seq runs num_txns
// times in the foreground. Once the foreground finishes, disable fork
// kills the background responder loop - this is the standard UVM pattern
// for "keep responding for as long as the other side is active".
//--------------------------------------------------------------------------------------------
class axi4_virtual_write_seq extends uvm_sequence;
  `uvm_object_utils(axi4_virtual_write_seq)
  `uvm_declare_p_sequencer(top_vseqr)

  rand int unsigned num_txns = 10;

  function new(string name = "axi4_virtual_write_seq");
    super.new(name);
  endfunction

  task body();
    cpu_write_seq        cpu_wr_seq;
    axi4_slave_write_seq slv_wr_seq;

    fork
      // Background: AXI4 slave VIP keeps accepting/responding to write
      // bursts for as long as the foreground branch below is running.
      begin
        forever begin
          slv_wr_seq = axi4_slave_write_seq::type_id::create("slv_wr_seq");
          slv_wr_seq.start(p_sequencer.slave_write_sqr_h);
        end
      end
      // Foreground: drive num_txns CPU writes.
      begin
        repeat (num_txns) begin
          cpu_wr_seq = cpu_write_seq::type_id::create("cpu_wr_seq");
          cpu_wr_seq.start(p_sequencer.cpu_sqr_h);
        end
      end
    join_any
    disable fork;
  endtask
endclass
