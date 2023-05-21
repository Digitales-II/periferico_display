module ram#(parameter IMAGEN="python/ext_mem.txt")(
    input wire i_clk,
    input wire request,
    output reg [35:0] o_valor
);
    reg [35:0] ext_mem [3200:0];
    reg [35:0] counter = 0;

    initial begin
        $readmemb(IMAGEN,ext_mem);
    end

    assign clk_req = i_clk & request;

    always @ (posedge clk_req) begin
        o_valor <= ext_mem[counter];
        if (counter == 3200) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
    
endmodule