module hs_bridge #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter H_POS = 14,
    parameter L_POS = 2
) (
    input logic clk,
    input logic rst,

    input  logic [WIDTH-1:0] data_in,
    input  logic             valid,
    output logic             ready,

    output logic [WIDTH-1:0] data_out,
    output logic             req,
    input  logic             ack
);

  logic [WIDTH-1:0] data_r = '0, fifo_out = '0;
  //   logic [WIDTH-1:0] mem_in = '0, mem_out = '0;
  logic full, empty, f_hs, fifo_re;
  logic fifo_val;
  assign ready = !full;

  typedef enum logic [1:0] {
    F_IDLE,
    F_FETCH
  } state_f;
  typedef enum logic [1:0] {
    B_IDLE,
    B_FETCH,
    B_WAIT_VAL,
    B_HS
  } state_b;
  state_f statef_reg = F_IDLE, statef_next;
  state_b stateb_reg = B_IDLE, stateb_next;
  always_comb begin
    f_hs = ready && valid;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      statef_reg <= F_IDLE;
    end else begin
      statef_reg <= statef_next;
    end
  end
  always_ff @(posedge clk) begin
    if (rst) begin
      stateb_reg <= B_IDLE;
    end else begin
      stateb_reg <= stateb_next;
    end
  end

  always_comb begin
    stateb_next = stateb_reg;
    case (stateb_reg)
      B_IDLE: begin
        if (!empty && !req && !ack) begin
          stateb_next = B_FETCH;
        end
      end
      B_FETCH: begin
        stateb_next = B_WAIT_VAL;
      end
      B_WAIT_VAL: begin
        if (fifo_val) begin
          stateb_next = B_HS;
        end
      end
      B_HS: begin
        if (req && ack) begin
          stateb_next = B_IDLE;
        end
      end
      default: begin
        stateb_next = B_IDLE;
      end
    endcase
  end
  always_ff @(posedge clk) begin
    if (rst) begin
      req      <= '0;
      fifo_re  <= '0;
      data_out <= '0;
    end else begin
      req      <= (stateb_next == B_HS);
      fifo_re  <= (stateb_next == B_FETCH);
      data_out <= fifo_val ? fifo_out : data_out;
    end
  end






  fifo #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH),
      .H_POS(H_POS),
      .L_POS(L_POS)
  ) fifo_inst (
      .clk    (clk),
      .rst    (rst),
      .we     (f_hs),
      .din    (data_in),
      .full   (full),
      .re     (fifo_re),
      .dout   (fifo_out),
      .empty  (empty),
      .val    (fifo_val),
      .ack    (fifo_ack),
      .p_full (p_full),
      .p_empty(p_empty)
  );
endmodule
