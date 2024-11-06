
module fifo_tb;

  // Parameters
  localparam WIDTH = 8;
  localparam DEPTH = 16;
  localparam H_POS = 14;
  localparam L_POS = 2;

  //Ports
  logic             clk = '0;
  logic             rst = '0;
  logic             we = '0;
  logic [WIDTH-1:0] din = '0;
  wire              full;
  logic             re = '0;
  wire  [WIDTH-1:0] dout;
  wire              empty;
  wire              val;
  wire              ack;
  wire              p_full;
  wire              p_empty;

  fifo #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH),
      .H_POS(H_POS),
      .L_POS(L_POS)
  ) fifo_inst (
      .clk    (clk),
      .rst    (rst),
      .we     (we),
      .din    (din),
      .full   (full),
      .re     (re),
      .dout   (dout),
      .empty  (empty),
      .val    (val),
      .ack    (ack),
      .p_full (p_full),
      .p_empty(p_empty)
  );

  always #5 clk = !clk;

  task automatic wr_drv(input logic [WIDTH-1:0] wdata);
    @(posedge clk);
    if (!full) begin
      we  <= 1'b1;
      din <= wdata;
    end

  endtask  //automatic
  task automatic fin_wr();
    @(posedge clk);
    we <= 1'b0;
  endtask  //automatic
  task automatic rd_drv();
    @(posedge clk);
    if (!empty) begin
      re <= 1'b1;
    end

  endtask  //automatic
  task automatic fin_rd();
    @(posedge clk);
    re <= 1'b0;
  endtask  //automatic
  task automatic wr_data(input int cnt);
    for (int i = 0; i < cnt; i++) begin
      wr_drv(i);
    end
    fin_wr();
  endtask  //automatic
  task automatic rd_data(input int cnt);
    for (int i = 0; i < cnt; i++) begin
      rd_drv();
    end
    fin_rd();
  endtask  //automatic
  task automatic reset();
    #50 rst = 1;
    #50 rst = 0;
    #50;
  endtask  //automatic
  initial begin
    reset();
    wr_data(16);
    rd_data(16);
    #20 $finish();
  end


endmodule
