`timescale 1ns/1ps

// =============================================================================
// 1-entry ready/valid buffer
// =============================================================================
// - Stores one data item.
// - Accepts a new item when empty, or when the current item is consumed in the
//   same cycle.
// - Holds out_valid_o and out_data_o stable while the downstream is stalled.
// =============================================================================
module rv_buffer #(
    parameter DW = 32
)(
    input  wire              clk_i,
    input  wire              rst_ni,

    input  wire              in_valid_i,
    output wire              in_ready_o,
    input  wire [DW-1:0]     in_data_i,

    output wire              out_valid_o,
    input  wire              out_ready_i,
    output wire [DW-1:0]     out_data_o
);

reg  [DW-1:0] buffer_r;
reg           valid_r;

wire          input_fire;
wire          output_fire;

// The buffer can accept data when it is empty, or when the current item will
// leave on this cycle. This allows one transfer per cycle after filling.
assign in_ready_o  = ~valid_r || out_ready_i;

assign out_valid_o = valid_r;
assign out_data_o  = buffer_r;

// Internal event names only; these are not additional protocol signals.
assign input_fire  = in_valid_i  && in_ready_o;
assign output_fire = out_valid_o && out_ready_i;

always @(posedge clk_i) begin
    if (!rst_ni) begin
        valid_r <= 1'b0;
    end
    else begin
        // Keep the current item until it is consumed, or mark the buffer valid
        // whenever a new item is accepted.
        valid_r <= (valid_r && !output_fire) || input_fire;

        // Data only needs to change when a new input transaction is accepted.
        if (input_fire) begin
            buffer_r <= in_data_i;
        end
    end
end

endmodule
