module SramRead (
	input i_clk,
	input i_rst_n,
	input [2:0] i_state,
	input [3:0] i_speed,
	input i_read_enable,    //from I2S
	input i_mode,
	input [19:0] record_end_addr,
	output reg [19:0] SRAM_ADDR, // SRAM Address
	input signed [15:0] SRAM_DQ, // SRAM Data port
	
	output reg [4:0] o_sram_ctrl,
	output reg [15:0] o_read_data,// after speed calculating
	output reg readdata_done,  //tell I2S to output audio signal to WM8731
	output reg read_finished
);

parameter IDLE   = 3'b000;
parameter PLAY   = 3'b001;
parameter PLAY_s = 3'b010;
parameter RECORD = 3'b011;
parameter RECORD_s = 3'b100;

logic [19:0] addr_count_w, addr_count_r;   //count the current register address
logic [19:0] sram_addr_tmp;
assign SRAM_ADDR = sram_addr_tmp;
logic [15:0] sram_data1_r, sram_data1_w;
logic [15:0] sram_data2_r, sram_data2_w;
logic [1:0]  process_counter_r, process_counter_w; //count for action,start count when read_n=1, 0=>store sram1 , 1=>store sram2, 2 interpolation(or not) and give answer 
logic [2:0]  internal_count_r, internal_count_w;
logic [4:0]  sram_ctrl;
assign o_sram_ctrl = sram_ctrl;


logic [15:0] slow_out;
slow_cal slow_cal1(sram_data1_r,sram_data2_r,internal_count_r,i_speed,i_mode,slow_out);

//sram data1,data2
always_comb begin
if(i_state==PLAY) begin
	if(i_read_enable&&process_counter_r==0) begin
		sram_ctrl = 5'b00001;
		sram_addr_tmp = addr_count_r;
		sram_data1_w = SRAM_DQ;
		sram_data2_w = sram_data2_r;
	end
	else if (process_counter_r==1) begin
		sram_data1_w = sram_data1_r;
		sram_data2_w = SRAM_DQ;
		sram_ctrl = 5'b00001;
		sram_addr_tmp = addr_count_r+1;
	end
	else begin
		sram_data1_w = sram_data1_r;
		sram_data2_w = sram_data2_r;
		sram_ctrl = 5'b10000;
		sram_addr_tmp = addr_count_r;
	end
end
else begin
		sram_data1_w = 0;
		sram_data2_w = 0;
		sram_ctrl = 5'b10000;
		sram_addr_tmp = 0;
end
end

//process counter =>control what to do
always_comb begin
	if(process_counter_r!=0) begin
		process_counter_w = process_counter_r+1;
	end
	else begin
		process_counter_w = 0;
	end

	if(i_state==PLAY) begin
	if(i_read_enable) begin
		process_counter_w = 1;
	end
	end
end

//done signal =>o_data is valid
always_comb begin
	if(process_counter_r==2'b11) begin
		readdata_done =1;
	end
	else begin
		readdata_done =0;	
	end
end

//o_read_data
logic debug1;
always_comb begin
//	o_read_data = 16'hxxxx;//0f00;

	if(i_speed>6) begin
		o_read_data = sram_data1_r;
		debug1=1;
	end
	else begin
		o_read_data = slow_out;
		debug1=0;
	end
end
//addr_count & internal_count
always_comb begin
	read_finished=0;
	if(i_speed>6)
		internal_count_w = 0;
	else
		internal_count_w = internal_count_r;

	if(i_state==PLAY||i_state==PLAY_s)
		addr_count_w = addr_count_r;
	else
		addr_count_w = 0;

if(i_state==PLAY)begin
	if(readdata_done) begin
		case (i_speed)
		0:  begin
			if(internal_count_r==7) begin
				addr_count_w = addr_count_r+1;
				internal_count_w = 0;
			end
			else begin
				addr_count_w = addr_count_r;
				internal_count_w = internal_count_r+1;
			end
			if(addr_count_r==20'hfffff || addr_count_r>record_end_addr-10)
				read_finished = 1;
		end
		1:  begin
			if(internal_count_r==6) begin
				addr_count_w = addr_count_r+1;
				internal_count_w = 0;
			end
			else begin
				addr_count_w = addr_count_r;
				internal_count_w = internal_count_r+1;
			end
			if(addr_count_r==20'hfffff|| addr_count_r>record_end_addr-10)
				read_finished = 1;
		end
		2:  begin
			if(internal_count_r==5) begin
				addr_count_w = addr_count_r+1;
				internal_count_w = 0;
			end
			else begin
				addr_count_w = addr_count_r;
				internal_count_w = internal_count_r+1;
			end
			if(addr_count_r==20'hfffff|| addr_count_r>record_end_addr-10)
				read_finished = 1;
		end
		3:  begin
			if(internal_count_r==4) begin
				addr_count_w = addr_count_r+1;
				internal_count_w = 0;
			end
			else begin
				addr_count_w = addr_count_r;
				internal_count_w = internal_count_r+1;
			end
			if(addr_count_r==20'hfffff|| addr_count_r>record_end_addr-10)
				read_finished = 1;
		end
		4:  begin
			if(internal_count_r==3) begin
				addr_count_w = addr_count_r+1;
				internal_count_w = 0;
			end
			else begin
				addr_count_w = addr_count_r;
				internal_count_w = internal_count_r+1;
			end
			if(addr_count_r==20'hfffff|| addr_count_r>record_end_addr-10)
				read_finished = 1;
		end
		5:  begin
			if(internal_count_r==2) begin
				addr_count_w = addr_count_r+1;
				internal_count_w = 0;
			end
			else begin
				addr_count_w = addr_count_r;
				internal_count_w = internal_count_r+1;
			end
			if(addr_count_r==20'hfffff|| addr_count_r>record_end_addr-10)
				read_finished = 1;
		end
		6:  begin
			if(internal_count_r==1) begin
				addr_count_w = addr_count_r+1;
				internal_count_w = 0;
			end
			else begin
				addr_count_w = addr_count_r;
				internal_count_w = internal_count_r+1;
			end
			if(addr_count_r==20'hfffff|| addr_count_r>record_end_addr-10)
				read_finished = 1;
		end
		7:  begin
			addr_count_w = addr_count_r+1;
			if(addr_count_r==20'hfffff|| addr_count_r>record_end_addr-10)
				read_finished = 1;
		end
		8:  begin
			if(addr_count_r>20'hffffd|| addr_count_r>record_end_addr-10) begin
				addr_count_w = 0;
				read_finished = 1;	
			end
			else
			addr_count_w = addr_count_r+2;
		end
		9:  begin
			if(addr_count_r>20'hffffc|| addr_count_r>record_end_addr-10) begin
				addr_count_w = 0;
				read_finished = 1;
			end
			else
			addr_count_w = addr_count_r+3;
		end
		10:  begin
			if(addr_count_r>20'hffffb|| addr_count_r>record_end_addr-10) begin
				addr_count_w = 0;
				read_finished = 1;
			end
			else
			addr_count_w = addr_count_r+4;
		end
		11:  begin
			if(addr_count_r>20'hffffa|| addr_count_r>record_end_addr-10) begin
				addr_count_w = 0;
				read_finished = 1;
			end
			else
			addr_count_w = addr_count_r+5;
		end
		12:  begin
			if(addr_count_r>20'hffff9|| addr_count_r>record_end_addr-10) begin
				addr_count_w = 0;
				read_finished = 1;
			end
			else
			addr_count_w = addr_count_r+6;
		end
		13:  begin
			if(addr_count_r>20'hffff8|| addr_count_r>record_end_addr-10) begin
				addr_count_w = 0;
				read_finished = 1;
			end
			else
			addr_count_w = addr_count_r+7;
		end
		14:  begin
			if(addr_count_r>20'hffff7|| addr_count_r>record_end_addr-10) begin
				addr_count_w = 0;
				read_finished = 1;
			end
			else
			addr_count_w = addr_count_r+8;
		end
		default: begin
			addr_count_w = 0;
			read_finished= 1;
		end
		endcase
	end	
end
end


always_ff @(posedge i_clk) begin if(~i_rst_n) begin
		addr_count_r <= 0;
		sram_data1_r <= 0;
		sram_data2_r <= 0;
		process_counter_r<=0;
		internal_count_r <=0;
	end else begin
		addr_count_r <= addr_count_w;
		sram_data1_r <= sram_data1_w;
		sram_data2_r <= sram_data2_w;
		process_counter_r<=process_counter_w;
		internal_count_r <=internal_count_w;
	end
end

endmodule
