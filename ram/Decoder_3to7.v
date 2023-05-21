module Decoder_3to7 (
  input wire [2:0] input_data,
  output wire [6:0] output_data
);

  reg [6:0] output_reg;

  always @* begin
    case (input_data)
      3'b001: output_reg = 7'b1000000;
      3'b010: output_reg = 7'b1100000;
      3'b011: output_reg = 7'b1110000;
      3'b100: output_reg = 7'b1111000;
      3'b101: output_reg = 7'b1111100;
      3'b110: output_reg = 7'b1111110;
      3'b111: output_reg = 7'b1111111;
      default: output_reg = 7'b0000000;
    endcase
  end

  assign output_data = output_reg;

endmodule