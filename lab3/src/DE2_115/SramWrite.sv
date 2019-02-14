module SramWrite(
	input 		  i_clk, 		//BCLK 12M
	input 		  i_rst_n,
	input  [2:0]  i_state,
	input  [15:0] i_data,
	input 		  i_datavalid,
	output [19:0] o_sram_addr,
	output [15:0] io_sram_data,
	output [4:0]  o_sram_ctrl,
	output  	  o_sram_addr_finished,
	output [19:0] record_end_addr
);
//local parameter?

parameter IDLE   = 3'b000;
parameter PLAY   = 3'b001;
parameter PLAY_s = 3'b010;
parameter RECORD = 3'b011;
parameter RECORD_s = 3'b100;

logic [4:0]  sram_ctrl;
logic [19:0] sram_addr_r,sram_addr_w;
assign o_sram_addr = sram_addr_r;
//logic [15:0] write_data;

assign o_sram_ctrl = sram_ctrl;

assign io_sram_data = i_state==RECORD? i_data: 16'bz;
assign o_sram_addr_finished = sram_addr_r==20'hffffe;

logic [19:0] record_end_addr_r,record_end_addr_w;
assign record_end_addr = record_end_addr_r;

//==============================================
//--------------Sequential part-----------------
//==============================================

always_comb begin
	sram_ctrl = 5'b10000;
	sram_addr_w = sram_addr_r;
	record_end_addr_w = record_end_addr_r;
	if(i_state==RECORD) begin
		if(i_datavalid) begin 
		//requirement: datavalid only rise for a full cycle of BCLK
			sram_addr_w = sram_addr_r+1;
			sram_ctrl = 5'b00000;
			record_end_addr_w = sram_addr_r;
		end	
	end
	else if(i_state==RECORD_s) begin
		sram_addr_w = sram_addr_r;
		record_end_addr_w = record_end_addr_r;
		sram_ctrl = 5'b10000;
	end
	else if(i_state==IDLE) begin
		sram_addr_w = 0;
	end
end



//==============================================
//--------------Combinational part--------------
//==============================================
//i_rst_n = 0 ==> reset
always_ff @(posedge i_clk) begin if(~i_rst_n) begin
		sram_addr_r <= 0;
		record_end_addr_r<=0;
	end else begin
		sram_addr_r <= sram_addr_w;
		record_end_addr_r<=record_end_addr_w;
	end
end

endmodule
