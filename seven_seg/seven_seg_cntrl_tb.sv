`timescale 1ns / 1ps  // <unit>/<precision>

module seven_seg_cntrl_tb ();

  int checks = 0;
  int errors = 0;

  logic clk = 0;
  logic reset;
  logic [15:0] digits;
  logic [6:0] seg;
  logic [3:0] an;

  logic [3:0] an_old = 4'b0000;
  int n_low;

  always #5 clk = ~clk;
  assign n_low  = $countones(~an);
  assign digits = 16'h3210;

  seven_seg_cntrl #(
      .CNT_WIDTH(3)
  ) dut (
      .clk(clk),
      .reset(reset),
      .digits(digits),
      .seg(seg),
      .an(an)
  );

  task automatic do_reset();
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
  endtask  // Automatic

  task automatic check_an(input logic [3:0] an, input logic [3:0] exp_an);
    checks++;
    if (an !== exp_an) begin
      errors++;
      $error("t=%0t an mismatch: got=%b, exp=%b", $time, an, exp_an);
    end
  endtask  // Automatic

  task automatic check_seg(input logic [6:0] seg, input logic [6:0] exp_seg);
    checks++;
    if (seg !== exp_seg) begin
      errors++;
      $error("t=%0t seg mismatch: got=%b, exp=%b", $time, seg, exp_seg);
    end
  endtask  //automatic

  task automatic do_verdict();
    if (errors == 0) begin
      $display("PASS: %0d checks, %0d mismatches", checks, errors);
    end else begin
      $fatal(1, "FAIL: %0d mismatches, %0d checks", errors, checks);
    end
    $finish;
  endtask  // Automatic

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, seven_seg_cntrl_tb);
    do_reset();

    #5000;

    do_verdict();
  end

  always @(negedge clk) begin
    if (reset) begin
      // Reset blanks the display
      check_seg(seg, ~7'b000_0000);
    end else checks++;
    // Ensure an one-cold
    if (n_low !== 1) begin
      errors++;
      $error("t=%0t multiple-an mismatch: got=%b", $time, an);
    end

    // Ensure legal an transitions
    an_old <= an;
    if (an !== an_old) begin
      checks++;
      case (an_old)
        4'b1110: check_an(an, 4'b1101);
        4'b1101: check_an(an, 4'b1011);
        4'b1011: check_an(an, 4'b0111);
        4'b0111: check_an(an, 4'b1110);
        default: begin
          if (an_old !== 4'b0000)
            $error("t=%0t transitions mismatch: an=%b, an_old=%b", $time, an, an_old);
        end
      endcase
    end
  end

endmodule
