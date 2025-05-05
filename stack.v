//############################################################################
//   2024 Digital Circuit and System Lab
//   Lab07       : stack
//   Author      : Ceres Lab 2025 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/03/07
//   Version     : v1.0
//   File Name   : stack.v
//   Module Name : stack
//############################################################################
//==============================================//
//           Top CPU Module Declaration         //
//==============================================//
module stack(
	// input ports
	clk,
	rst_n, 
	data_in, 
	cmd, 
	// output ports
	data_out, 
	full, 
	empty 
); 

input 	    clk, rst_n; 
input [7:0] data_in;  	   /* input data for push operations */
input [1:0] cmd;      	   /* 00: no operation, 01: clear, 10: push, 11: pop */ 

output reg [7:0] data_out; /* retrieved data for pop operations, changes at posedge clk */ 
output reg       full;     /* flag set when the stack is full */ 
output reg       empty;    /* flag set when the stack is empty */ 

reg [7:0] RAM [0:7];	   /* 8 X 8 memory module to hold stack data */ 


// Start Your Design

parameter nop = 2'b00, clear = 2'b01, push = 2'b10, pop = 2'b11;

integer i;

reg [7:0] data_in_reg;
reg [1:0] cmd_reg;

reg [3:0] pointer;

// INPUT BUFFER
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) cmd_reg <= 2'b0;
	else cmd_reg <= cmd;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) data_in_reg <= 8'b0; 
	else data_in_reg <= data_in;
end

// STACK
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<8; i=i+1) begin
			RAM[i] <= 8'b0;
		end
		pointer <= 3'b0;
	end
	else begin
		case(cmd_reg)
			nop: begin
				for(i=0; i<8; i=i+1) begin
					RAM[i] <= RAM[i];
				end
				pointer <= pointer;
			end
			clear: begin
				for(i=0; i<8; i=i+1) begin
					RAM[i] <= 8'b0;
				end
				pointer <= 3'b0;
			end
			push: begin
				for(i=0; i<8; i=i+1) begin
					if(i == pointer) RAM[i] <= data_in_reg;
					else RAM[i] <= RAM[i];
				end
				pointer <= pointer + 1;
			end
			pop: begin
				for(i=0; i<8; i=i+1) begin
					if(i == pointer - 1) RAM[i] <= 8'b0;
					else RAM[i] <= RAM[i];
				end
				pointer <= pointer - 1;
			end
			default: begin
				for(i=0; i<8; i=i+1) begin
					RAM[i] <= RAM[i];
				end
				pointer <= pointer;
			end
		endcase
	end
end

// DATA OUT
always @(*) begin
	if(cmd_reg == pop) data_out = RAM[pointer-1];
	else data_out = 8'b0;
end

// STATUS FLAG
always @(*) begin
	if(cmd_reg == clear) full = 1'b0;
	else if((pointer == 8'd8 && (cmd_reg !== pop)) || ((pointer == 8'd7) && (cmd_reg == push))) full = 1'b1;
	else full = 1'b0;
end

always @(*) begin
	if(((pointer == 8'd0) && (cmd_reg !== push)) || (cmd_reg == clear) || ((pointer == 8'd1) && (cmd_reg == pop))) empty = 1'b1;
	else empty = 1'b0;
end

endmodule






