//############################################################################
//   2024 Digital Circuit and System Lab
//   HW04        : IP and Pipeline
//   Author      : Ceres Lab 2025 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/02/28
//   Version     : v1.0
//   File Name   : TESTBED.v
//   Module Name : TESTBED
//############################################################################

`timescale 1ns/10ps

`include "PATTERN.v"
`ifdef RTL
  `include "stack.v"
`endif
`ifdef GATE
  `include "stack_SYN.v"
`endif

	  		  	
module TESTBED;

wire          clk, rst_n;
wire [1:0]    cmd;         
wire [7:0]    data_in;

wire          full, empty;
wire [7:0]    data_out;

initial begin
  `ifdef RTL
    $fsdbDumpfile("stack.fsdb");
    $fsdbDumpvars(0,"+mda");
    $fsdbDumpvars();
  `endif
  `ifdef GATE
    $sdf_annotate("stack_SYN.sdf", u_stack);
    $fsdbDumpfile("stack_SYN.fsdb");
    $fsdbDumpvars();    
  `endif
end

`ifdef RTL
stack u_stack(
    .clk(clk),
    .rst_n(rst_n),
    .cmd(cmd),
    .data_in(data_in),
    .full(full),
    .empty(empty),
    .data_out(data_out)
    );
`endif

`ifdef GATE
stack u_stack(
    .clk(clk),
    .rst_n(rst_n),
    .cmd(cmd),
    .data_in(data_in),
    .full(full),
    .empty(empty),
    .data_out(data_out)
    );
`endif

PATTERN u_PATTERN(
    .clk(clk),
    .rst_n(rst_n),
    .cmd(cmd),
    .data_in(data_in),
    .full(full),
    .empty(empty),
    .data_out(data_out)
    );
  
 
endmodule
