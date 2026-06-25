module tff_tb ();

  // DUT inputs/outputs
  logic clk = 0;
  logic reset;
  logic t;
  logic q;

  int   errors = 0;
  int   checks = 0;

  always #5 clk = ~clk;

  tff dut (
      .clk(clk),
      .reset(reset),
      .t(t),
      .q(q)
  );

  // Input stimulus (expected_q checks run concurrently in a separate block)
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tff_tb);

    reset = 1;
    t = 0;

    @(posedge clk);
    @(posedge clk);  // Two edges so the design settles into a known state
    #1 reset = 0;  // Deassert just after the edge

    // Targeted scenarios

    // t held high then low: toggles every edge, then holds
    #1 t = 1;
    repeat (10) @(posedge clk);
    #1 t = 0;
    repeat (10) @(posedge clk);

    // Reset check
    @(posedge clk);
    #1 reset = 1;
    @(posedge clk);
    #1 reset = 0;
    repeat (10) @(posedge clk);

    // Randomized scenarios
    for (int i = 0; i < 200; i++) begin
      @(posedge clk);
      #1 t = 1'($urandom());
    end

    @(posedge clk);  // Let final t get sampled + checked

    // Verdict
    if (errors == 0) begin
      $display("PASS: %0d checks, %0d mismatches", checks, errors);
    end else begin
      $fatal(1, "FAIL: %0d mismatches, %0d checks", errors, checks);
    end
    $finish;
  end

  // Reference model state
  int   toggle_count = 0;
  logic expected_q;

  always @(posedge clk) begin
    if (reset) begin
      toggle_count <= 0;
    end else if (t) begin
      toggle_count <= toggle_count + 1;
    end
  end

  assign expected_q = toggle_count[0];  // Low bit equals count mod 2

  // Comparison between expected and DUT
  always @(negedge clk) begin  // Compare on negedge to avoid the edge where q updates
    checks++;
    if (q !== expected_q) begin
      $error("t=%0t: q=%b expected=%b", $time, q, expected_q);
      errors++;
    end
  end

endmodule
