module fsm_hdlc_tb ();

  int   errors = 0;
  int   checks = 0;

  logic clk = 0;
  logic reset;
  logic in;
  logic disc;
  logic flag;
  logic err;

  // Pattern library for all flags (drive() shifts bracketing zeros out)
  localparam logic [7:0] PatDisc = 8'b00111110;
  localparam logic [7:0] PatFlag = 8'b01111110;
  localparam logic [7:0] PatErr  = 8'b01111111;


  always #5 clk = ~clk;

  fsm_hdlc dut (
      .clk(clk),
      .reset(reset),
      .in(in),
      .disc(disc),
      .flag(flag),
      .err(err)
  );

  task automatic check(input string name, input logic got, input logic exp);
    checks++;
    if (got !== exp) begin
      errors++;
      $error("t=%0t %s mismatch: got=%b  exp=%b", $time, name, got, exp);
    end
  endtask  // Automatic

  task automatic do_reset();
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
  endtask  // Automatic

  // Drive len bits of pattern MSB-first, one bit per clock
  task automatic drive(input logic [7:0] pattern, input int len);
    for (int i = len - 1; i >= 0; i--) begin
      #1 in = pattern[i];
      @(posedge clk);
    end
  endtask  // Automatic

  // Drive the same pattern amount times back-to-back
  task automatic back_to_back(input logic [7:0] pattern, input int len, input int amount);
    repeat (amount) drive(pattern, len);
  endtask  // Automatic

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, fsm_hdlc_tb);
    do_reset();

    for (int i = 1; i < 11; i++) begin
      #1 in = 1;
      repeat (i) @(posedge clk);
      #1 in = 0;
      @(posedge clk);
    end

    #1 in = 0;
    repeat (10) @(posedge clk);

    for (int i = 1; i < 11; i++) begin
      in = 1;
      repeat (i) @(posedge clk);
      #1 reset = 1;
      @(posedge clk);
      #1 reset = 0;
    end

    @(posedge clk);

    back_to_back(PatDisc, 7, 10);
    back_to_back(PatFlag, 8, 10);

    // Pattern butted against a stuffed sequence
    drive(PatFlag, 8);
    drive(PatDisc, 7);

    // Repeated err
    drive(PatErr, 7);
    repeat (20) begin
      #1 in = 1;
      @(posedge clk);
    end
    #1 in = 0;
    @(posedge clk);

    @(posedge clk);

    // Random sweep
    repeat (1000) begin
      #1 in = 1'($urandom);
      @(posedge clk);
    end

    // Verdict
    if (errors == 0) begin
      $display("PASS: %0d checks, %0d mismatches", checks, errors);
    end else begin
      $fatal(1, "FAIL: %0d mismatches, %0d checks", errors, checks);
    end
    $finish;
  end

  // Reference model

  logic [7:0] history;
  logic exp_disc;
  logic exp_flag;
  logic exp_err;

  // history is registered on purpose: the DUT decodes its outputs from a registered
  // state, causing each output to fire one cycle after the terminating bit.
  always @(posedge clk) begin
    if (reset) begin
      history <= 8'd0;
    end else begin
      history <= {history[6:0], in};
    end
  end

  assign exp_disc = (history[6:0] == PatDisc[6:0]);
  assign exp_flag = (history      == PatFlag);
  assign exp_err  = (history[6:0] == PatErr[6:0]);

  // Comparison to DUT
  always @(negedge clk) begin
    if (!reset) begin
      check("disc", disc, exp_disc);
      check("flag", flag, exp_flag);
      check("err", err, exp_err);

      checks++;
      if (disc & flag | flag & err | err & disc) begin
        errors++;
        $error("t=%0t duplicate: disc=%b, flag=%b, err=%b", $time, disc, flag, err);
      end
    end
  end
endmodule
