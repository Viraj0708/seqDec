<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements an adaptable sequence detector in Verilog.

It receives a serial bitstream on input pin ui_in[0].

The sequence length is provided on pins ui_in[5:1] (up to 31 bits).

The target sequence pattern is provided through ui_in[7:0] and uio_in[7:0] (combined into a 16-bit value for demo, extendable up to 32 bits).

Internally, the design uses a shift register to capture the most recent input bits.

On every clock cycle, the shift register contents are compared with the programmed pattern, masked according to the sequence length.

If a match is detected, the output uo_out[0] goes high for one cycle.

This makes the detector adaptable — you can configure both the length and the exact bit pattern to detect without modifying the HDL code.

## How to test

Simulation

Run the provided testbench (tb.v) in EDA Playground or Icarus Verilog.

The testbench:

Resets the design.

Configures it to detect the sequence 1011 (length = 4).

Sends a sample bitstream 1,0,1,1,1,0,1,1.

You should see two matches detected (output pulse at cycle 4 and cycle 7).

Open the generated tb.vcd file in GTKWave/EPWave to visualize signals.

On FPGA / TinyTapeout

Provide a serial bitstream on ui_in[0] (LSB).

Set ui_in[5:1] to the desired sequence length.

Provide the pattern bits through ui_in[7:0] and uio_in[7:0].

Monitor uo_out[0] → it pulses high whenever the programmed sequence appears in the input stream.

## External hardware

None required.

The design works standalone and only requires the clock and reset provided by TinyTapeout.

For physical FPGA testing, you may connect:

A button or serial source to ui_in[0] for bit input.

LEDs to uo_out[0] to observe match pulses.
