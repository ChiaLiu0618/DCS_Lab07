//############################################################################
//   2024 Digital Circuit and System Lab
//   HW04        : IP and Pipeline
//   Author      : Ceres Lab 2025 MS1 Student
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/02/28
//   Version     : v1.0
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//############################################################################
`define CYCLE_TIME 10
`define PAT_NUM 200

module PATTERN(
	// output ports
	clk,
 	rst_n, 
	data_in, 
	cmd, 
	// input ports
	data_out, 
	full, 
	empty 
); 
//==============================================//
//               Parameter & Integer            //
//==============================================//
// PATTERN operation
parameter CYCLE = `CYCLE_TIME;

// PATTERN CONTROL
integer cycle_time = CYCLE;
integer total_latency;
integer latency;
integer MAX_LATENCY = 7;
integer pat_num = `PAT_NUM;
integer i_pat, j_pat;
parameter PATNUM_SIMPLE = 100;
integer   SEED = 587;


//==============================================//
//          Input & Output Declaration          //
//==============================================//
output reg clk, rst_n;
output reg [7:0] data_in;
output reg [1:0] cmd;

input full, empty;
input [7:0] data_out;

//==============================================//
//                 Signal Declaration           //
//==============================================//
reg start_validation;
reg [1:0] _cmd_ff;
reg [7:0] _din_ff;
reg _golden_full, _golden_empty;
reg _full_ff, _empty_ff;
reg _full_cmb, _empty_cmb;
reg [7:0] _golden_dout, _dout_cmb;
reg [7:0] _RAM [0:7];
reg [7:0] _RAM_cmb [0:7];
reg [2:0] _sp_cmb, _sp_ff;
wire [2:0] _r_ptr, _w_ptr;

integer _i, _j;
parameter _NOP 		= 0;
parameter _CLEAR 	= 1;
parameter _PUSH		= 2;
parameter _POP 		= 3;
//==============================================//
//                 String control               //
//==============================================//
// Should use %0s
string reset_color          = "\033[1;0m";
string txt_black_prefix     = "\033[1;30m";
string txt_red_prefix       = "\033[1;31m";
string txt_green_prefix     = "\033[1;32m";
string txt_yellow_prefix    = "\033[1;33m";
string txt_blue_prefix      = "\033[1;34m";
string txt_magenta_prefix   = "\033[1;35m";
string txt_cyan_prefix      = "\033[1;36m";

string bkg_black_prefix     = "\033[40;1m";
string bkg_red_prefix       = "\033[41;1m";
string bkg_green_prefix     = "\033[42;1m";
string bkg_yellow_prefix    = "\033[43;1m";
string bkg_blue_prefix      = "\033[44;1m";
string bkg_white_prefix     = "\033[47;1m";

//==============================================//
//                main function                 //
//==============================================//
// clock
always begin
	#(CYCLE/2);
	clk = ~clk;
end

initial begin
	reset_task;
	total_latency = 0;
	input_task;
end

initial begin
	wait_validation_task;
	check_ans_task;
    you_pass_task;
end
 

//==============================================//
//            Clock and Reset Function          //
//==============================================//
// reset task
task reset_task; begin	
	// initiaize signal
	clk = 0;
	rst_n = 1;
    cmd = 2'b00;
    data_in = 'dx;
	start_validation = 0;

	// force clock to be 0, do not flip in half cycle
	force clk = 0;

	#(CYCLE*3);
	
	// reset
	rst_n = 0;  #(CYCLE*5); // wait 5 cycles to check output signal
	// check reset

    //check all outputs reset
    if(data_out !== 0 || full !== 'd0 || empty !== 'd1) begin
        $display("%0s================================================================", txt_red_prefix);
		$display("                             FAIL"                           );
		$display("              All outputs should be restet !   ");
		$display("================================================================%0s", reset_color);
		// #(CYCLE*8);
        $finish;
    end

	// release reset
	rst_n = 1; #(CYCLE*3);
	
	// release clock
	release clk; repeat(5) @ (negedge clk);
end endtask


//==============================================//
//            Generate input pattern            //
//==============================================//
integer rand_idx, rand_num;
integer set_NoPush 	[0:2] = '{0, 1, 3};
reg [1:0] cmd_tmp;
reg [7:0] din_tmp; 

// input task 
task input_task; begin
    for (i_pat = 0; i_pat < pat_num; i_pat = i_pat + 1) begin
		@(negedge clk);
		if(i_pat==21 || i_pat==60 || i_pat==95 || i_pat==73 || i_pat==123 || i_pat==167 || i_pat==168 ) begin
			full_task;		// create stack full scenario
			rand_idx = $urandom % 3;
			rand_num = set_NoPush[rand_idx];
			cmd_tmp = rand_num;
			din_tmp = 'dx;
		end	else if(i_pat==26 || i_pat==66 || i_pat==91 || i_pat==70 || i_pat==124 || i_pat==158 || i_pat==176 ) begin
			empty_task;		// create stack empty scenario
			rand_num = $urandom % 3;
			cmd_tmp = rand_num;
			din_tmp = (cmd_tmp == 2'b10)? ($urandom % 256) : 'dx;
		end else begin
			if(_golden_full) begin
				rand_idx = $urandom % 3;
				rand_num = set_NoPush[rand_idx];
				cmd_tmp = rand_num;
				din_tmp = 'dx;
			end else if(_golden_empty) begin
				rand_num = $urandom % 3;
				cmd_tmp = rand_num;
				din_tmp = (cmd_tmp == 2'b10)? ($urandom % 256) : 'dx;
			end else begin
				rand_num = $urandom % 4;
				cmd_tmp = rand_num;
				din_tmp = (cmd_tmp == 2'b10)? ($urandom % 256) : 'dx;
			end
		end

		start_validation = (i_pat > 'd1);
		cmd = cmd_tmp;
		data_in = din_tmp;
	end
	@(negedge clk);
	@(negedge clk);
	start_validation = 0;
end endtask

task full_task; begin
	while(!_golden_full) begin
		cmd = 2'b10;
		data_in = $urandom % 256;
		@(negedge clk);
	end
end endtask

task empty_task; begin
	while(!_golden_empty) begin
		cmd = 2'b11;
		data_in = 'dx;
		@(negedge clk);
	end
end endtask


//==============================================//
//            Calculate golden data             //
//==============================================//
// Stack
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		_cmd_ff <= 0;
		_din_ff <= 0;
	end else begin
		_cmd_ff <= cmd;
		_din_ff <= data_in;
	end
end

always @(posedge clk) begin
	for (_i=0; _i<8; _i=_i+1)
		_RAM[_i] <= _RAM_cmb[_i];
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		// _golden_dout <= 'd0;
		_full_ff <= 0;
		_empty_ff <= 1;
	end else begin
		// _golden_dout <= _dout_cmb;
		_full_ff <= _golden_full;
		_empty_ff <= _golden_empty; 
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	_sp_ff <= 3'd0;
	else		_sp_ff <= _sp_cmb;		
end

// stack pointer (sp) control 
always @(*) begin
	case (_cmd_ff)
		_NOP 	: _sp_cmb = _sp_ff;
		_CLEAR 	: _sp_cmb = 3'd0;
		_PUSH 	: _sp_cmb = _sp_ff + 'd1;
		_POP 	: _sp_cmb = _sp_ff - 'd1; 
		default : _sp_cmb = _sp_ff; 
	endcase
end

assign _r_ptr = _sp_ff - 1;
assign _w_ptr = _sp_ff;

// stack RAM control
always @(*) begin
	for(_j=0; _j<8; _j=_j+1)	
		_RAM_cmb[_j] = _RAM[_j];
	
	if(_cmd_ff == _PUSH)	_RAM_cmb[_w_ptr] = _din_ff;  
end

// full flag control
always @(*) begin
	_golden_full = _full_ff;
	case (_cmd_ff)
		_NOP 	: _golden_full = _full_ff;
		_CLEAR 	: _golden_full = 0;
		_PUSH 	: _golden_full = (_w_ptr == 3'd7);
		_POP	: _golden_full = 0;
		default	: _golden_full = _full_ff;
	endcase
end

// empty flag control
always @(*) begin
	_golden_empty = _empty_ff;
	case (_cmd_ff)
		_NOP	: _golden_empty = _empty_ff;
		_CLEAR	: _golden_empty = 1;
		_PUSH	: _golden_empty = 0;
		_POP	: _golden_empty = (_sp_ff == 'd1);	 
		default	: _golden_empty = _empty_ff; 
	endcase
end

// data_out control
// assign _dout_cmb = (_cmd_ff == _POP)? _RAM[_r_ptr] : 0;
assign _golden_dout = (_cmd_ff == _POP)? _RAM[_r_ptr] : 0;


//==============================================//
//            Check design function             //
//==============================================//
// wait for start validation flag
task wait_validation_task; begin
	while (start_validation !== 'd1) begin
		@(negedge clk);
	end
end endtask

// check answer task 
task check_ans_task; 
begin
    j_pat = 0;
    while (start_validation === 'd1) begin
        // check output correctness
        if(full !== _golden_full || empty !== _golden_empty || data_out !== _golden_dout) begin
            $display("%0s===========================================================================", txt_red_prefix);
		    $display("                             		FAIL"                           );
		    $display("                       Output is incorret at PATTERN NO.%4d  ", j_pat);
			$display("               golden answer : full=%b, empty=%b, data_out=%d  ", _golden_full, _golden_empty, _golden_dout);
			$display("               your answer   : full=%b, empty=%b, data_out=%d  ", full, empty, data_out);
		    $display("=============================================================================%0s", reset_color);
            #(CYCLE*2);
            $finish;
		end else begin
			$display("%0sPASS PATTERN NO.%4d %0s",txt_blue_prefix, j_pat, reset_color);
		end
        @(negedge clk);
        j_pat = j_pat + 1;
    end
end endtask

//==============================================//
//            Pass and Finish Function          //
//==============================================//
// you_pass task
task you_pass_task; begin
	$display("                                           `:::::`                                                       ");
    $display("                                          .+-----++                                                      ");
    $display("                .--.`                    o:------/o                                                      ");
    $display("              /+:--:o/                   //-------y.          -//:::-        `.`                         ");
    $display("            `/:------y:                  `o:--::::s/..``    `/:-----s-    .:/:::+:                       ");
    $display("            +:-------:y                `.-:+///::-::::://:-.o-------:o  `/:------s-                      ");
    $display("            y---------y-        ..--:::::------------------+/-------/+ `+:-------/s                      ");
    $display("           `s---------/s       +:/++/----------------------/+-------s.`o:--------/s                      ");
    $display("           .s----------y-      o-:----:---------------------/------o: +:---------o:                      ");
    $display("           `y----------:y      /:----:/-------/o+----------------:+- //----------y`                      ");
    $display("            y-----------o/ `.--+--/:-/+--------:+o--------------:o: :+----------/o                       ");
    $display("            s:----------:y/-::::::my-/:----------/---------------+:-o-----------y.                       ");
    $display("            -o----------s/-:hmmdy/o+/:---------------------------++o-----------/o                        ");
    $display("             s:--------/o--hMMMMMh---------:ho-------------------yo-----------:s`                        ");
    $display("             :o--------s/--hMMMMNs---------:hs------------------+s------------s-                         ");
    $display("              y:-------o+--oyhyo/-----------------------------:o+------------o-                          ");
    $display("              -o-------:y--/s--------------------------------/o:------------o/                           ");
    $display("               +/-------o+--++-----------:+/---------------:o/-------------+/                            ");
    $display("               `o:-------s:--/+:-------/o+-:------------::+d:-------------o/                             ");
    $display("                `o-------:s:---ohsoosyhh+----------:/+ooyhhh-------------o:                              ");
    $display("                 .o-------/d/--:h++ohy/---------:osyyyyhhyyd-----------:o-                               ");
    $display("                 .dy::/+syhhh+-::/::---------/osyyysyhhysssd+---------/o`                                ");
    $display("                  /shhyyyymhyys://-------:/oyyysyhyydysssssyho-------od:                                 ");
    $display("                    `:hhysymmhyhs/:://+osyyssssydyydyssssssssyyo+//+ymo`                                 ");
    $display("                      `+hyydyhdyyyyyyyyyyssssshhsshyssssssssssssyyyo:`                                   ");
    $display("                        -shdssyyyyyhhhhhyssssyyssshssssssssssssyy+.                                      ");
    $display("                         `hysssyyyysssssssssssssssyssssssssssshh+                                        ");
    $display("                        :yysssssssssssssssssssssssssssssssssyhysh-                                       ");
    $display("                      .yyhhdo++oosyyyyssssssssssssssssssssssyyssyh/                                      ");
    $display("                      .dhyh/--------/+oyyyssssssssssssssssssssssssy:                                     ");
    $display("                       .+h/-------------:/osyyysssssssssssssssyyh/.                                      ");
    $display("                        :+------------------::+oossyyyyyyyysso+/s-                                       ");
    $display("                       `s--------------------------::::::::-----:o                                       ");
    $display("                       +:----------------------------------------y`                                      ");
	$display("%0s======================================================================================================", txt_magenta_prefix);
	$display("                                     Congratulations!!");
    $display("                                    All Pattern Test Pass");
	$display("                                      Cycle time = %-2d ns", cycle_time);
	// $display("                         Your execution cycles = %-4d cycles", total_latency);
	$display("========================================================================================================= %0s", reset_color);
	$finish;
end	endtask


endmodule
