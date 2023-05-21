/*module led_control (
  input clk,
  input enable,
  output led
);
  always @(posedge clk) begin
    if (enable) begin
      led <= 1'b1;
    end else begin
      led <= 1'b0;
    end
  end
endmodule*/
module pantalla(
    // Input clock to our panel driver
    input wire i_clk,
    //input enable,
    // Shift register controls for the column data
    output reg o_data_clock,
    output reg o_data_latch,
    output reg o_data_blank,
    // Data lines to be shifted
    output reg [1:0] o_data_r,
    output reg [1:0] o_data_g,
    output reg [1:0] o_data_b,
    // Inputs to the row select demux
    output reg [4:0] o_row_select
);

    // How many pixels to shift per row
    localparam pixels_per_row = 160;

    // State machine IDs
    localparam
        s_data_shift = 0,
        s_blank_set = 1,
        s_latch_set = 2,
        s_increment_row = 3,
        s_latch_clear = 4,
        s_blank_clear = 5;

    // Simple colour cycling logic. We will have a prescaler that counts down
    // to zero twice per second, based on the frequency of our module input
    // clock (`CLOCK_HZ`).
    // Whenever this countdown hits zero, we will increment our colour state
    // register, each bit of which is mapped to the reg, green or blue data
    // channel of the RGB panel shift registers.
    /*localparam COLOUR_CYCLE_PRESCALER = (25000000 / 2) - 1;
    reg [$clog2(COLOUR_CYCLE_PRESCALER):0] colour_cycle_counter = 0;
    reg [2:0] colour_register;*/
    /*always @(posedge i_clk) begin
        if (enable) begin
		    colour_register <= colour_register + 1;
	    end
        //colour_register = 0;
    end*/
    /*always @(posedge i_clk) begin
        if (colour_cycle_counter == 0) begin
            colour_register <= colour_register + 1;
            colour_cycle_counter <= COLOUR_CYCLE_PRESCALER;
        end else
            colour_cycle_counter <= colour_cycle_counter - 1;
    end*/

    // Connect the output colour data lines to our colour counter
    assign o_data_r = {colour_register[0], colour_register[0]};
    assign o_data_g = {colour_register[1], colour_register[1]};
    assign o_data_b = {colour_register[2], colour_register[2]};

    // Register to keep track of where we are in our panel update state machine
    reg [2:0] state = s_data_shift;
    // How many pixels remain to be shifted in the 'data_shift' state
    reg [7:0] pixels_to_shift;
    always @(posedge i_clk) begin
        case (state)
        s_data_shift: begin // Shift out new column data for this row
            if (pixels_to_shift > 0) begin
                // We have data to shift still
                if (o_data_clock == 1) begin
                    // For this test, we have hardcoded our colour output, so
                    // there is nothing to do per-pixel here
                    o_data_clock <= 0;
                end else begin
                    o_data_clock <= 1;
                    pixels_to_shift <= pixels_to_shift - 8;
                end
            end else
               state <= s_blank_set;
         end
         // In order to update the column data, these shift registers actually
         // seem to require the output is disabled before they will latch new
         // data. So to perform an update, we have a series of steps here that
         // - Blank the output
         // - Latch the new data
         // - Increment to the new row address
         // - Reset the latch state
         // - Unblank the display.
         // Each step has been made it's own state for clarity; if one wanted
         // to save a little more on logic some of these steps can be merged.
         s_blank_set: begin o_data_blank <= 1; state <= s_latch_set; end
         s_latch_set: begin o_data_latch <= 1; state <= s_increment_row; end
         s_increment_row: begin o_row_select <= o_row_select + 1;
                                state <= s_latch_clear; end
         s_latch_clear: begin o_data_latch <= 0; state <= s_blank_clear; end
         s_blank_clear: begin
             o_data_blank <= 0;
             pixels_to_shift <= pixels_per_row;
             state <= s_data_shift;
         end
        endcase
    end
endmodule