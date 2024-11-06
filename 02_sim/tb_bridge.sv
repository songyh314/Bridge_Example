`timescale 1ns/10ps
module hs_bridge_tb;

  // Parameters
  localparam WIDTH = 8;
  localparam DEPTH = 16;
  localparam H_POS = 14;
  localparam L_POS = 2;

  //Ports
  logic             clk = '0;
  logic             rst = '0;
  logic [WIDTH-1:0] data_in = '0;
  logic             valid = '0;
  wire              ready;
  wire  [WIDTH-1:0] data_out;
  wire              req;
  logic             ack = '0;

  hs_bridge #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH),
      .H_POS(H_POS),
      .L_POS(L_POS)
  ) hs_bridge_inst (
      .clk     (clk),
      .rst     (rst),
      .data_in (data_in),
      .valid   (valid),
      .ready   (ready),
      .data_out(data_out),
      .req     (req),
      .ack     (ack)
  );
  class Vec;
    rand bit [WIDTH-1:0] rand_data;
  endclass  //Vec

  Vec vec = new();

  always #5 clk = !clk;
  task automatic reset();
    repeat (5) @(posedge clk);
    rst = 1'b1;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    repeat (5) @(posedge clk);
  endtask  //automatic

  task automatic wr_drv();
    if (!vec.randomize) begin
      $display("rand failed");
    end
    @(posedge clk);
    valid   <= 1'b1;
    data_in <= vec.rand_data;
    #1 wait (valid && ready);
  endtask  //automatic
  task automatic fin_wr();
    @(posedge clk);
    valid <= 1'b0;
  endtask //automatic

  task automatic write(input int cnt);
    for (int i = 0; i < cnt; i++) begin
      wr_drv();
    end
    fin_wr();
  endtask  //automatic

  task automatic gen_ack();
    wait(req);
    @(posedge clk) ack <= 1'b1;
    wait(!req);
    @(posedge clk) ack <= 1'b0;
  endtask //automatic

  initial begin
    reset();
    write(20);
    #20 $finish();
  end
  initial begin
    forever begin
      gen_ack();
    end
  end
endmodule
