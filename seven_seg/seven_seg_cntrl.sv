module seven_seg_cntrl #(
    parameter int CNT_WIDTH = 17
) (
    input logic clk,
    input logic reset,
    input logic [15:0] digits,  // BCD
    output logic [6:0] seg,
    output logic [3:0] an
);
  // Bit order: g f e d c b a
  localparam logic [6:0] SEG_0 = 7'b011_1111;
  localparam logic [6:0] SEG_1 = 7'b000_0110;
  localparam logic [6:0] SEG_2 = 7'b101_1011;
  localparam logic [6:0] SEG_3 = 7'b100_1111;
  localparam logic [6:0] SEG_4 = 7'b110_0110;
  localparam logic [6:0] SEG_5 = 7'b110_1101;
  localparam logic [6:0] SEG_6 = 7'b111_1101;
  localparam logic [6:0] SEG_7 = 7'b000_0111;
  localparam logic [6:0] SEG_8 = 7'b111_1111;
  localparam logic [6:0] SEG_9 = 7'b110_1111;
  localparam logic [6:0] SegNan = 7'b100_0000;
  localparam logic [6:0] SegReset = 7'b000_0000;

  logic [CNT_WIDTH-1:0] cnt;
  logic [3:0] dis_num;

  // Refresh counter (~1.52 kHz cnt from 100 MHz clk)
  always_ff @(posedge clk) begin
    if (reset) cnt <= 0;
    else cnt <= cnt + 1;
  end

  // Digit selector (anode)
  always_comb begin
    case (cnt[CNT_WIDTH-1-:2])
      0: an = 4'b1110;
      1: an = 4'b1101;
      2: an = 4'b1011;
      3: an = 4'b0111;
      default: an = 4'b1111;
    endcase
  end

  // Number selector
  always_comb begin
    case (cnt[CNT_WIDTH-1-:2])
      0: dis_num = digits[3:0];
      1: dis_num = digits[7:4];
      2: dis_num = digits[11:8];
      3: dis_num = digits[15:12];
      default: dis_num = 4'b1111;  // Error
    endcase
  end

  // BCD-to-7seg decoder (seg = active-low)
  always_comb begin
    if (reset) seg = ~SegReset;
    else begin
      case (dis_num)
        0: seg = ~SEG_0;
        1: seg = ~SEG_1;
        2: seg = ~SEG_2;
        3: seg = ~SEG_3;
        4: seg = ~SEG_4;
        5: seg = ~SEG_5;
        6: seg = ~SEG_6;
        7: seg = ~SEG_7;
        8: seg = ~SEG_8;
        9: seg = ~SEG_9;
        default: seg = ~SegNan;  // Error
      endcase
    end
  end

endmodule
