`timescale 1ns/10ps

`include "SramRead.sv"
`include "Slow_cal.sv"
`define CYCLE 10

module testbench();

logic i_clk12M;
logic i_sw_rst;
logic [2:0] state_r;
logic [15:0] i_sram_data;
logic i_sram_write_enable;
logic o_sram_addr_write;
logic [15:0] SRAM_DQ;
logic sram_ctrl_write;
logic sram_write_finished;
logic record_end_addr_w;



SramWrite SramWrite1(
	.i_clk(i_clk12M), 		//BCLK 12M
	.i_rst_n(i_sw_rst),
	.i_state(state_r),
	.i_data(i_sram_data),
	.i_datavalid(i_sram_write_enable),
	.o_sram_addr(o_sram_addr_write),
	.io_sram_data(SRAM_DQ),
	.o_sram_ctrl(sram_ctrl_write),
	.o_sram_addr_finished(sram_write_finished), //addr is full
	.record_end_addr(record_end_addr_w)
);

initial begin
   i_clk12M       = 1'b0;
   i_sw_rst       = 1'b0; 
    #2 i_sw_rst = 1'b0;                            
    #5 i_sw_rst = 1'b1;
    #8
       state_r = 3'b011;//PLAY
    #(3*`CYCLE) 
       i_sram_data=16'hfeff;
       i_sram_write_enable=1;
       i_sw_intp=0;
    #(1.1*`CYCLE) 
    i_sram_read_require=0;
    
    #(9.9*`CYCLE)
    	//state_r = 3'b000;
    #(10*`CYCLE)
       state_r = 3'b001;//PLAY
       speed_r = 4'd7;
    #(3*`CYCLE) 
       i_sram_data=16'hfeff;
       i_sram_write_enable=1;
       i_sw_intp=0;
    #(1.1*`CYCLE) 
    i_sram_read_require=0;
    
	#680 $finish;
end


always begin #(`CYCLE/2) i_clk12M = ~i_clk12M; end

initial begin
   $dumpfile("RSACore.fsdb");
   $dumpvars;
end
endmodule



