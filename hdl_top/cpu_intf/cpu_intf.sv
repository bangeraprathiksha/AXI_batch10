interface cpu_intf(input bit clk);

  logic rst;
  logic wr_en;
  logic rd_en;
  logic [127:0] wr_data;
  logic full;
  logic [127:0] rd_data;
  logic empty;

  // Driver Clocking Block
  clocking drv_cb @(posedge clk);
    default input #1 output #0;
    output rst,wr_en,rd_en,wr_data;
    input full,empty,rd_data;
  endclocking

  // Monitor Clocking Block
  clocking mon_cb @(posedge clk);
    default input #1 output #0;
    input rst,wr_en,rd_en,wr_data,full,empty,rd_data;
  endclocking

endinterface
