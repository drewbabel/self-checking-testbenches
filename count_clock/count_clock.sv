// 12-hour BCD clock: seconds, minutes, hours, AM/PM
module count_clock (
    input logic clk,
    input logic reset,
    input logic ena,
    output logic pm,  // 0 = AM, 1 = PM
    output logic [7:0] hh,
    output logic [7:0] mm,
    output logic [7:0] ss
);

  logic ss_c, mm_c;

  counter #(
      .DEFAULT(8'h00),
      .LIMIT(8'h59),
      .WRAP(8'h00)
  ) seconds (
      .clk(clk),
      .reset(reset),
      .ena(ena),
      .c_out(ss_c),
      .q(ss)
  );

  counter #(
      .DEFAULT(8'h00),
      .LIMIT(8'h59),
      .WRAP(8'h00)
  ) minutes (
      .clk(clk),
      .reset(reset),
      .ena(ss_c),
      .c_out(mm_c),
      .q(mm)
  );

  counter #(
      .DEFAULT(8'h12),
      .LIMIT(8'h12),
      .WRAP(8'h01)
  ) hours (
      .clk(clk),
      .reset(reset),
      .ena(mm_c),
      .c_out(),
      .q(hh)
  );

  always @(posedge clk) begin
    if (reset) pm <= 1'b0;
    else if ((hh == 8'h11) & mm_c) pm <= ~pm;
  end

endmodule

module counter #(
    // All BCD, 2 digits = 8 bits each
    parameter logic [7:0] DEFAULT,
    logic [7:0] LIMIT,
    logic [7:0] WRAP
) (
    input logic clk,
    input logic reset,
    input logic ena,
    output logic c_out,
    output logic [7:0] q  // BCD
);
  logic c_local;

  assign c_local = (q[3:0] == 4'h9);
  assign c_out   = ((q == 8'(LIMIT)) & ena);

  always_ff @(posedge clk) begin
    if (reset) q <= DEFAULT;
    else if (ena) begin
      if (c_out) q <= WRAP;  // Overflowing limit = wrap around
      else begin  // Otherwise: increment counter
        q[3:0] <= (c_local) ? 4'h0 : q[3:0] + 4'h1;  // Singles digit
        if (c_local) q[7:4] <= q[7:4] + 4'h1;  // Tens digit
      end
    end
  end
endmodule
