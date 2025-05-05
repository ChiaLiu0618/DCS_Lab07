# Digital Circuit and System - Lab07: Stack Implementation

**Institute of Electronics, NYCU**  
**NYCU CERES LAB**  
**March 7, 2025**

## Introduction

This lab focuses on the implementation of a hardware stack using a Finite State Machine (FSM). A stack follows the Last-In-First-Out (LIFO) principle and is commonly used in hardware and software systems for temporary data storage. The goal of this lab is to design a pipelined stack that correctly handles various stack operations with specific timing constraints and interface protocols.

## Stack Overview

- **Stack Behavior**: Last-In-First-Out (LIFO)
- **Commands Supported**:
  - `nop`: No operation, stack remains unchanged.
  - `clear`: Clears all data in the stack.
  - `push`: Pushes a new data item onto the stack.
  - `pop`: Pops the top data item from the stack and outputs it.

- **Status Flags**:
  - `full`: Asserted when the stack is full.
  - `empty`: Asserted when the stack is empty or just cleared.

- **Constraints**:
  - A `push` command is never given when `full` is asserted.
  - A `pop` command is never given when `empty` is asserted.

## I/O Ports

### Input
- `clk`: Clock signal (positive edge triggered)
- `rst_n`: Active-low asynchronous reset
- `cmd[1:0]`: 2-bit command signal
- `data_in[7:0]`: 8-bit data input

### Output
- `data_out[7:0]`: 8-bit data output (result of `pop`)
- `full`: High when stack is full
- `empty`: High when stack is empty or cleared

## Implementation Specifications

- All output signals must be reset properly after the reset is asserted.
- After reset, the stack status should be empty, and `data_out` must be `8'd0`.
- The entire design must be synchronous and positive-edge triggered.
- Use two DFFs for registering both `cmd` and `data_in` (as per the block diagram).
- You are **not allowed to change** the cycle time (fixed at **10 ns**).
- Input external delay is set to `0.5 * cycle`.

## Command Behavior (Waveform Summary)

- **NOP (`cmd=2'd0`)**: No change to stack or output. All signals remain the same.
- **CLEAR (`cmd=2'd1`)**: Resets the stack. Pattern checks if `empty` is asserted at the specified negedge of clk.
- **PUSH (`cmd=2'd2`)**: Adds a new value. `full` must be asserted when the stack has one slot left and `cmd_ff = push`.
- **POP (`cmd=2'd3`)**: Outputs the last item. `empty` must be asserted when the stack has one element left and `cmd_ff = pop`. `data_out` is verified at the specified negedge.

## Simulation and Testing

### Flow
1. **RTL Simulation**:  
   Run: `./01_run_vcs_rtl`

2. **Synthesis (TSMC 40nm)**:  
   Run: `./01_run_dc_shell`  
   Ensure: Timing met (slack > 0), no latches, no errors in `syn.log`

3. **Gate-Level Simulation**:  
   Run: `./01_run_vcs_gate`  
   Check: `./08_check` for no violations

4. **Submission**:  
   Run: `./00_tar` → creates `10.0.tar.gz`  
   Submit via: `./01_submit`

### Scoring
- **Function Validity**: 100%
- Pass required for:
  - `01_RTL`
  - `02_SYN`
  - `03_GATE`
- Clock period is fixed at **10 ns**. Do not modify.
