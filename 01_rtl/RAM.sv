module RAM #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
    input  logic                     clk,
    input  logic                     re,
    input  logic [$clog2(DEPTH)-1:0] raddr,
    output logic [        WIDTH-1:0] dout,
    output logic                     val,
    input  logic [$clog2(DEPTH)-1:0] waddr,
    input  logic                     we,
    input  logic [        WIDTH-1:0] din,
    output logic                     ack
);

  logic [WIDTH-1:0] mem[DEPTH] = '{default: '0};
  logic re_r1, we_r1;
  logic [WIDTH-1:0] din_r = '0;
  logic [$clog2(DEPTH)-1:0] raddr_r1 = '0, waddr_r1 = '0;

  always_ff @(posedge clk) begin
    {re_r1, we_r1}       <= {re, we};
    {val, ack}           <= {re_r1, we_r1};
    din_r                <= din;
    {raddr_r1, waddr_r1} <= {raddr, waddr};
    // dout_r <= mem[waddr_r1];
  end
  always_ff @(posedge clk) begin
    if (re_r1) begin
      dout <= mem[raddr_r1];
    end
  end
  always_ff @(posedge clk) begin
    if (we_r1) begin
      mem[waddr_r1] <= din_r;
    end
  end


endmodule
