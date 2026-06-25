// HDLC bit-stream FSM: detect bit-stuffing discard, flag (6 ones), and error (7+ ones)
module fsm_hdlc (
    input  logic clk,
    input  logic reset,  // Synchronous reset
    input  logic in,
    output logic disc,
    output logic flag,
    output logic err
);

  typedef enum {
    DATA,
    DISC,
    FLAG,
    ERR
  } state_t;
  state_t state, next_state;
  logic [2:0] cnt;

  always_comb begin
    next_state = state;
    disc = 1'b0;
    flag = 1'b0;
    err = 1'b0;
    case (state)
      DATA: begin
        if (!in) begin
          if (cnt == 3'd6) next_state = FLAG;
          else if (cnt == 3'd5) next_state = DISC;
        end else if (cnt == 3'd6) next_state = ERR;
      end

      DISC: begin
        disc = 1'b1;
        next_state = DATA;
      end

      FLAG: begin
        flag = 1'b1;
        next_state = DATA;
      end

      ERR: begin
        err = 1'b1;
        if (!in) next_state = DATA;
      end

      default: next_state = DATA;  // Illegal/unknown state -> recover to reset state
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      state <= DATA;  // Reset assumes previous in = 0
      cnt   <= 3'd0;
    end else begin
      state <= next_state;
      if (in) begin
        if (!(cnt == 7)) cnt <= cnt + 3'd1;
      end else cnt <= 3'd0;
    end
  end
endmodule
