//--------------------------------------------------------------------------------------------
// Class: axi4_virtual_read_seq
// NEW FILE. Read-side counterpart of axi4_virtual_write_seq - see that file's
// header comment for the reasoning behind the fork/join_any/disable fork
// structure.
//
// Runs at the same time, each on its own sequencer:
//   - cpu_read_seq         -> cpu_sqr_h             (drives the CPU read side,
//                                                     new file: tb/cpu_agent/cpu_read_seq.sv)
//   - axi4_slave_read_seq  -> slave_read_sqr_h       (drives the AXI4 slave VIP
//                                                      read response side)
//--------------------------------------------------------------------------------------------
class axi4_virtual_read_seq extends uvm_sequence;
  `uvm_object_utils(axi4_virtual_read_seq)
  `uvm_declare_p_sequencer(top_vseqr)

  rand int unsigned num_txns = 10;

  function new(string name = "axi4_virtual_read_seq");
    super.new(name);
  endfunction

  task body();
    cpu_read_seq         cpu_rd_seq;
    axi4_slave_read_seq  slv_rd_seq;

    fork
      // Background: AXI4 slave VIP keeps responding to read bursts for as
      // long as the foreground branch below is running.
      begin
        forever begin
          slv_rd_seq = axi4_slave_read_seq::type_id::create("slv_rd_seq");
          slv_rd_seq.start(p_sequencer.slave_read_sqr_h);
        end
      end
      // Foreground: drive num_txns CPU reads.
      begin
        repeat (num_txns) begin
          cpu_rd_seq = cpu_read_seq::type_id::create("cpu_rd_seq");
          cpu_rd_seq.start(p_sequencer.cpu_sqr_h);
        end
      end
    join_any
    disable fork;
  endtask
endclass
