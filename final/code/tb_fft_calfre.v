`timescale  1ns/10ps
`define  CYCLE 4
`include "fft_control.v"
`include "fft_control_2.v"
`include "fft_calfre.v"
`include "vector_cordic_3.v"
`include "collect_voice.v"
module tb_fft_calfre();

reg clk;
reg rst_n;
/*
wire [17:0] sink_real, sink_imag;
wire sink_startofpacket, sink_endofpacket, sink_valid;

reg [15:0] i_sram_data;
reg source_startofpacket, source_endofpacke, source_valid;
reg [5:0]  source_exp;
reg [17:0] source_real, source_imag;


fft_control fft_control1(
.clk(clk),
.rst_n(rst_n),

.i_sram_data(i_sram_data),
.source_valid(source_valid),
.source_real(source_real),
.source_imag(source_imag),
.source_exp(source_exp),
.source_startofpacket(source_startofpacket),
.source_endofpacket(source_endofpacke),

.sink_real(sink_real),
.sink_imag(sink_imag),
.sink_startofpacket(sink_startofpacket),
.sink_endofpacket(sink_endofpacket),
.sink_valid(sink_valid)
);*/
initial begin
        $fsdbDumpfile("collect_voice.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA();
end/*
reg  source_startofpacket;
reg [17:0] source_real, source_imag;
reg [5:0]  source_exp;
reg        source_valid;
wire[15:0] o_frequency;
wire 	   o_valid;
wire[5:0]  ex;
wire[15:0] fre;

wire[4:0]  magn;
wire[14:0] max_magn;
wire[20:0] max_id;

fft_calfre fft_calfre2(
.clk(clk), //750k
.rst_n(rst_n),
.source_startofpacket(source_startofpacket),
.source_real(source_real),
.source_imag(source_imag),
.source_exp(source_exp),
.source_valid(source_valid),

.o_frequency(o_frequency),
.o_display_ex(ex),
.o_display_fre(fre),
.o_display_magn(magn),
.o_display_max_magn(max_magn),
.o_display_max_id(max_id)
);


initial begin
	source_valid = 1;
	source_startofpacket = 0;
	source_real = 0;
	source_imag = 0;
	source_exp  = 0;
	clk = 1'b0;
	rst_n = 1'b1;
#2  rst_n = 1'b0;
#10	rst_n = 1'b1;
#`CYCLE
	source_startofpacket = 1;
	source_real = 18'd100;
	source_imag = 18'd90;
	source_exp  = -1;
#`CYCLE
	source_startofpacket = 0;
	source_real = 18'd1000;
	source_imag = 18'd900;
	source_exp  = 0;
#`CYCLE
	source_startofpacket = 0;
	source_real = 18'd1020;
	source_imag = 18'd920;
	source_exp  = 3;
#`CYCLE
	source_startofpacket = 0;
	source_real = 18'd3100;
	source_imag = 18'd390;
	source_exp  = 0;
#`CYCLE
	source_startofpacket = 0;
	source_real = 18'd6100;
	source_imag = 18'd690;
	source_exp  = -4;
#`CYCLE
	source_startofpacket = 0;
	source_real = 18'd0;
	source_imag = 18'd0;
	source_exp  = 0;
#(`CYCLE*1020)
	source_startofpacket = 1;
	source_real = 18'd100;
	source_imag = 18'd90;
	source_exp  = 0;
#`CYCLE
	source_startofpacket = 0;
	source_real = 18'd1000;
	source_imag = 18'd900;
	source_exp  = 0;
#`CYCLE
	source_startofpacket = 0;
	source_real = 18'd1000;
	source_imag = 18'd900;
	source_exp  = 0;
#`CYCLE	
	source_startofpacket = 0;
	source_real = 18'd0;
	source_imag = 18'd0;
	source_exp  = 0;
#20000 $finish;
end
*/

reg  [15:0] i_sram_data;
wire [15:0] o_sram_data_256;
reg  [10:0] cont;
collect_voice collect_voice(
.clk(clk),
.rst(rst_n),
.i_sram_data(i_sram_data), 
.o_sram_data_256(o_sram_data_256)
);

integer i;
initial begin
clk   = 1;
rst_n = 1;
i_sram_data = 0;
cont  = 0;

#(`CYCLE*1.2)
	rst_n = 0;
#(`CYCLE*8)
	rst_n = 1;
	i_sram_data = 16'd10;
#`CYCLE
	i_sram_data = 16'd9;
#`CYCLE
	i_sram_data = 16'd8;
#`CYCLE
	i_sram_data = 16'd9;
for(i=0;i<1750;i=i+1)
	#`CYCLE
		i_sram_data = cont;
//#(`CYCLE*750)
//	i_sram_data = 16'd8	
#50 $finish;
end

always begin #(`CYCLE/2) clk = ~clk; end
always begin #(`CYCLE)   cont = cont+1; end


endmodule



