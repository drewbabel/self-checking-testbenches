// Self-checking testbench for count_clock: reference model vs DUT BCD outputs
module count_clock_tb ();

  int errors = 0;
  int checks = 0;

  logic clk = 0;
  logic reset;
  logic ena;
  logic pm;
  logic [7:0] hh;
  logic [7:0] mm;
  logic [7:0] ss;

  always #5 clk = ~clk;

  count_clock dut (
      .clk(clk),
      .reset(reset),
      .ena(ena),
      .pm(pm),
      .hh(hh),
      .mm(mm),
      .ss(ss)
  );

  task automatic do_reset();
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
  endtask  // Automatic

  task automatic check(input string name, input logic [7:0] got, input logic [7:0] exp);
    checks++;
    if (got !== exp) begin
      errors++;
      $error("t=%0t  %s mismatch: got=%02h  exp=%02h", $time, name, got, exp);
    end
  endtask  // Automatic

  // Pack a 0-99 value into two BCD nibbles
  function automatic logic [7:0] to_bcd(input int v);
    return 8'(((v / 10) << 4) | (v % 10));
  endfunction  // Automatic

  // Stimulus
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, count_clock_tb);
    do_reset();

    #1 ena = 1;
    repeat (172800) @(posedge clk);
    #1 ena = 0;
    repeat (5400) @(posedge clk);
    @(posedge clk);
    #1 reset = 1;
    @(posedge clk);
    #1 reset = 0;
    repeat (5400) @(posedge clk);
    #1 ena = 1;
    @(posedge clk);
    #1 reset = 1;
    @(posedge clk);
    #1 reset = 0;
    repeat (5400) @(posedge clk);

    @(posedge clk);

    // Verdict
    if (errors == 0) begin
      $display("PASS: %0d checks, %0d mismatches", checks, errors);
    end else begin
      $fatal(1, "FAIL: %0d mismatches, %0d checks", errors, checks);
    end
    $finish;
  end

  // Reference model
  int total_hh;
  int total_mm;
  int total_ss;

  logic expected_pm;
  int expected_hh;
  int expected_mm;
  int expected_ss;

  logic [7:0] exp_hh_bcd;
  logic [7:0] exp_mm_bcd;
  logic [7:0] exp_ss_bcd;

  always @(posedge clk) begin
    if (reset) begin
      total_ss <= 0;
    end else if (ena) begin
      total_ss <= (total_ss == 86399) ? 0 : total_ss + 1;
    end
  end

  always_comb begin
    total_hh = total_ss / 3600;
    total_mm = (total_ss / 60) % 60;

    expected_pm = (total_ss >= 43200);
    expected_hh = (total_hh % 12 == 0) ? 12 : total_hh % 12;
    expected_mm = total_mm % 60;
    expected_ss = total_ss % 60;

    // exp_hh_bcd = 8'(((expected_hh / 10) << 4) | (expected_hh % 10));
    // exp_mm_bcd = 8'(((expected_mm / 10) << 4) | (expected_mm % 10));
    // exp_ss_bcd = 8'(((expected_ss / 10) << 4) | (expected_ss % 10));
    exp_hh_bcd = to_bcd(expected_hh);
    exp_mm_bcd = to_bcd(expected_mm);
    exp_ss_bcd = to_bcd(expected_ss);
  end

  // Comparison to DUT
  always @(negedge clk) begin
    check("pm", {8{pm}}, {8{expected_pm}});
    check("hh", hh, exp_hh_bcd);
    check("mm", mm, exp_mm_bcd);
    check("ss", ss, exp_ss_bcd);
  end
endmodule
