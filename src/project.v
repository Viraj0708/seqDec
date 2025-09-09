/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // =====================================================
  // Adaptable Sequence Detector
  // =====================================================

  localparam MAX_N = 32;

  // Inputs
  wire        data_in  = ui_in[0];       // Serial input bit
  wire [4:0]  seq_len  = ui_in[5:1];     // Sequence length (up to 31 bits)
  wire [MAX_N-1:0] pattern = {uio_in, ui_in}; 
  // Example: pattern comes from 8-bit uio_in + 8-bit ui_in

  // Internal shift register
  reg [MAX_N-1:0] shift_reg;

  // Mask based on seq_len
  wire [MAX_N-1:0] mask;
  assign mask = (seq_len == 0) ? {MAX_N{1'b0}} :
                (({MAX_N{1'b1}}) >> (MAX_N - seq_len));

  // Pattern match logic
  wire match_comb = ((shift_reg & mask) == (pattern & mask)) && (seq_len != 0);

  // Registered match pulse
  reg match_reg;
  always @(posedge clk) begin
    if (!rst_n) begin
      shift_reg <= {MAX_N{1'b0}};
      match_reg <= 1'b0;
    end else begin
      shift_reg <= {shift_reg[MAX_N-2:0], data_in};
      match_reg <= match_comb;
    end
  end

  // =====================================================
  // Outputs
  // =====================================================
  assign uo_out  = {7'b0, match_reg};  // match on bit0, rest 0
  assign uio_out = 8'b0;               // unused
  assign uio_oe  = 8'b0;               // all IOs are inputs

  // =====================================================
  // Unused signals to prevent warnings
  // =====================================================
  wire _unused = &{ena, 1'b0};

endmodule


 
