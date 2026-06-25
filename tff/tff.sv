// T flip-flop: toggles q on each clock when t is high, sync reset clears q
module tff (
    input  logic clk,
    input  logic reset,
    input  logic t,
    output logic q
);

  always_ff @(posedge clk) begin
    if (reset) begin
      q <= 1'b0;
    end else begin
      q <= (t) ? ~q : q;
    end
  end
endmodule
