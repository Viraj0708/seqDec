`default_nettype none
`timescale 1ns / 1ps

/* This testbench instantiates the tt_um_example sequence detector
   and sets up signals for GTKWave/EPWave viewing.
*/
module tb ();

  // =====================================================
  // Clock Generation
  // =====================================================
  reg clk = 0;
  always #5 clk = ~clk;   // 100 MHz clock (10 ns period)

  // =====================================================
  // Inputs and Outputs
  // =====================================================
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // =====================================================
  // DUT Instantiation
  // =====================================================
  tt_um_example user_project (
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (0=input, 1=output)
      .ena    (ena),      // Always high when design is selected
      .clk    (clk),      // Clock
      .rst_n  (rst_n)     // Active-low reset
  );

  // =====================================================
  // Waveform Dump
  // =====================================================
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // =====================================================
  // Stimulus
  // =====================================================
  initial begin
    // Initialize
    ena    = 1;
    rst_n  = 0;
    ui_in  = 8'b0;
    uio_in = 8'b0;

    #20;
    rst_n = 1;

    // Configure: detect 1011
    // seq_len = 4 → ui_in[5:1] = 00100
    // data_in = driven on ui_in[0]
    ui_in[5:1] = 5'b00100; 
    uio_in     = 8'b00001011;  // pattern[7:0] = 1011

    // Feed bits: 1,0,1,1,1,0,1,1
    ui_in[0] = 1; #10;  // bit 1
    ui_in[0] = 0; #10;  // bit 0
    ui_in[0] = 1; #10;  // bit 1
    ui_in[0] = 1; #10;  // bit 1 -> match expected
    ui_in[0] = 1; #10;  // overlap start
    ui_in[0] = 0; #10;
    ui_in[0] = 1; #10;  // match again
    ui_in[0] = 1; #10;

    #50;
    $finish;
  end

endmodule

