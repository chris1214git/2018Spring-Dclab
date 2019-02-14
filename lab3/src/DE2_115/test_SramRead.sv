`timescale 1ns/10ps

`include "SramRead.sv"
`include "Slow_cal.sv"
`define CYCLE 10

module testbench();

logic i_clk12M;
logic i_sw_rst;
logic [2:0] state_r;
logic [3:0] speed_r;
logic i_sram_read_require;
logic i_sw_intp;
logic [19:0] o_sram_addr_read;
logic [15:0] SRAM_DQ;
logic [4:0] sram_ctrl_read;
logic [15:0] o_sram_data;
logic sram_readdata_valid;
logic sram_read_finished;
logic [19:0] record_end_addr;

SramRead SramRead1(
	.i_clk(i_clk12M),
	.i_rst_n(i_sw_rst),
	.i_state(state_r),
	.i_speed(speed_r),
	.i_read_enable(i_sram_read_require),    //from I2S
	.i_mode(i_sw_intp),//zero=0 interpolation=1
	.record_end_addr(record_end_addr),
	.SRAM_ADDR(o_sram_addr_read), // SRAM Address
	.SRAM_DQ(SRAM_DQ), // SRAM Data port
	.o_sram_ctrl(sram_ctrl_read),
	.o_read_data(o_sram_data),// after speed calculating
	.readdata_done(sram_readdata_valid),  //tell I2S to output audio signal to WM8731
	.read_finished(sram_read_finished)
);

initial begin
   i_clk12M       = 1'b0;
   i_sw_rst       = 1'b0; 
    #2 i_sw_rst = 1'b0;                            
    #5 i_sw_rst = 1'b1;
    #8
       record_end_addr=20'hfffff;
       state_r = 3'b001;//PLAY
       speed_r = 4'd7;
    #(3*`CYCLE) 
       i_sram_read_require=1;
       i_sw_intp=0;
       SRAM_DQ=16'hff00;
    #(1.1*`CYCLE) 
    SRAM_DQ=16'hff01;
    i_sram_read_require=0;
    
    #(9.9*`CYCLE)
    	//state_r = 3'b000;
    #(10*`CYCLE)
       state_r = 3'b001;//PLAY
       speed_r = 4'd7;
    #(3*`CYCLE) 
       i_sram_read_require=1;
       i_sw_intp=0;
       SRAM_DQ=16'hff00;
    #(1*`CYCLE) SRAM_DQ=16'hff01;
    i_sram_read_require=0;

	#680 $finish;
end


always begin #(`CYCLE/2) i_clk12M = ~i_clk12M; end

initial begin
   $dumpfile("RSACore.fsdb");
   $dumpvars;
end
endmodule



