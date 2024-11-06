module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter H_POS = 14,
    parameter L_POS = 2
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             we,
    input  logic [WIDTH-1:0] din,
    output logic             full,

    input  logic             re,
    output logic [WIDTH-1:0] dout,
    output logic             empty,
    output logic             val,
    output logic             ack,

    output logic p_full,
    output logic p_empty
);

  localparam ADDR_WIDTH = $clog2(DEPTH);
  logic [ADDR_WIDTH-1:0] raddr = '0, waddr = '0;
  logic [ADDR_WIDTH-1:0] w_ptr = '0, w_ptr_next;
  logic [ADDR_WIDTH-1:0] r_ptr = '0, r_ptr_next;
  logic [DEPTH-1:0] entries = '0, entries_next;
  logic [WIDTH-1:0] mem_in;

  logic mem_we = '0, mem_re = '0;
  logic mem_we_next, mem_re_next;
  logic p_full_reg = '0, p_empty_reg = '0;
  logic p_full_next, p_empty_next;
  logic full_next, empty_next;
  assign p_full  = p_full_reg;
  assign p_empty = p_empty_reg;

  always_comb begin
    mem_we_next = we && !full;
    mem_re_next = re && !empty;
  end

  always_comb begin
    r_ptr_next = r_ptr;
    if (mem_re_next) begin
      if (r_ptr_next == (DEPTH - 1'b1)) begin
        r_ptr_next = '0;
      end else begin
        r_ptr_next = r_ptr_next + 1'b1;
      end
    end
  end
  always_comb begin
    w_ptr_next = w_ptr;
    if (mem_we_next) begin
      if (w_ptr_next == (DEPTH - 1'b1)) begin
        w_ptr_next = '0;
      end else begin
        w_ptr_next = w_ptr_next + 1'b1;
      end
    end
  end
  always_comb begin
    entries_next = entries;
    case ({
      re, we
    })
      2'b00:   entries_next = entries;
      2'b01:   entries_next = (entries < DEPTH) ? entries + 1'b1 : entries;
      2'b10:   entries_next = (|entries) ? entries - 1'b1 : entries;
      2'b11:   entries_next = entries;
      default: entries_next = entries;
    endcase
  end
  always_comb begin
    p_full_next  = entries_next >= H_POS;
    full_next    = entries_next == DEPTH;
    empty_next   = entries_next == '0;
    p_empty_next = entries_next <= L_POS;
  end


  always_ff @(posedge clk) begin
    if (rst) begin
      mem_we      <= '0;
      mem_re      <= '0;
      entries     <= '0;
      p_full_reg  <= 1'b0;
      p_empty_reg <= 1'b1;
      full        <= 1'b0;
      empty       <= 1'b1;
      r_ptr       <= '0;
      w_ptr       <= '0;
      mem_in      <= '0;
      waddr <= '0;
      raddr <= '0;
      // mem_out     <= '0;
    end else begin
      mem_we      <= mem_we_next;
      mem_re      <= mem_re_next;
      entries     <= entries_next;
      p_full_reg  <= p_full_next;
      p_empty_reg <= p_empty_next;
      full        <= full_next;
      empty       <= empty_next;
      w_ptr       <= w_ptr_next;
      r_ptr       <= r_ptr_next;
      mem_in      <= din;
      waddr <= w_ptr;
      raddr <= r_ptr;
      // mem_out     <= dout;
    end
  end

  RAM #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH)
  ) RAM_inst (
      .clk  (clk),
      .re   (mem_re),
      .raddr(r_ptr),
      .dout (dout),
      .val  (val),
      .waddr(w_ptr),
      .we   (mem_we),
      .din  (mem_in),
      .ack  (ack)
  );

endmodule
