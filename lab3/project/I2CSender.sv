module I2CSender(
	input i_start,
	input [23:0] i_dat,
	input i_clk,
	input i_rst,
	output o_finished,
	output o_sclk,
	inout o_sdat
);

localparam S_IDLE = 0;
localparam S_START = 1;
localparam S_TRANS = 2;
localparam S_FINISH = 3;

logic [1:0] state_r, state_w;
logic [4:0] byte_counter_r, byte_counter_w;
logic [2:0] bit_counter_r, bit_counter_w;
logic [1:0] clk_counter_r, clk_counter_w;
logic [23:0] i_dat_r, i_dat_w;
logic oe_r, oe_w;      //output enable
logic o_sdat_r, o_sdat_w;  //SRAM_data


assign o_finished = (state_r==S_IDLE) && (!i_start);
assign o_sclk = (clk_counter_r==0 || clk_counter_r==3) ? 1 : 0 ;
assign o_sdat = oe_r ? o_sdat_r : 1'bz;

always_comb begin
	state_w = state_r;
	byte_counter_w = byte_counter_r;
	bit_counter_w = bit_counter_r;
	clk_counter_w = clk_counter_r;
	i_dat_w = i_dat_r;
	oe_w = oe_r;
	o_sdat_w = o_sdat_r;
	
	

	case (state_r) 
		S_IDLE: begin
			if(i_start==1) begin
				state_w = S_START;
				byte_counter_w = 0;
				bit_counter_w = 0;
				clk_counter_w = 0;
				i_dat_w = i_dat;
				oe_w = 1;
				o_sdat_w = 0;			// 1 -> 0 => start
			end
			else begin
				state_w = state_r;
				byte_counter_w = byte_counter_r;
				bit_counter_w = bit_counter_r;
				clk_counter_w = clk_counter_r;
				i_dat_w = i_dat_r;
				oe_w = oe_r;
				o_sdat_w = o_sdat_r;
			end
		end
		S_START: begin				//execute for one cycle
			clk_counter_w = clk_counter_r + 1;
			if(clk_counter_r==1) begin
				state_w = S_TRANS;
				byte_counter_w = byte_counter_r;
				bit_counter_w = bit_counter_r;
				i_dat_w = i_dat_r << 1;
				oe_w = oe_r;
				o_sdat_w = i_dat_r[23];
			end
			else begin
				state_w = state_r;
				byte_counter_w = byte_counter_r;
				bit_counter_w = bit_counter_r;
				i_dat_w = i_dat_r;
				oe_w = oe_r;
				o_sdat_w = o_sdat_r;
			end
		end
		S_TRANS : begin
			clk_counter_w = clk_counter_r + 1;
			if(clk_counter_r==1) begin
				if(bit_counter_r != 7) begin      //Haven't transmitted 8 bits
					bit_counter_w = bit_counter_r + 1;
					o_sdat_w = i_dat_r[23];
					i_dat_w = i_dat_r << 1;
				end
				else begin						  //Have transmitted 8 bits
					if(oe_r==1) oe_w = 0;		//enable to accept ACK for one cycle
					else begin
						oe_w = 1;
						if(byte_counter_r==2) begin
							state_w = S_FINISH;
							o_sdat_w = 0;
						end
						else begin
							byte_counter_w = byte_counter_r + 1;
							bit_counter_w = 0;
							o_sdat_w = i_dat_r[23];
							i_dat_w = i_dat_r << 1;
						end
					end
				end
			end
			else begin
				state_w = state_r;
				byte_counter_w = byte_counter_r;
				bit_counter_w = bit_counter_r;
				i_dat_w = i_dat_r;
				oe_w = oe_r;
				o_sdat_w = o_sdat_r;
			end
		end
		S_FINISH : begin
			if(clk_counter_r==0 || clk_counter_r==3) begin
				clk_counter_w = 0;
				o_sdat_w = 1;
				state_w = S_IDLE;
			end
			else begin
				clk_counter_w = clk_counter_r + 1;
				o_sdat_w = o_sdat_r;
				state_w = state_r;
			end
		end
	
	endcase

end

always_ff @(posedge i_clk) begin
	if (!i_rst) begin
		state_r <= S_IDLE;
		i_dat_r <= 0;
		oe_r <= 1;
		o_sdat_r <= 1;
		byte_counter_r <= 0;
		bit_counter_r <= 0;
		clk_counter_r <= 0;
		
	end
	else begin
		state_r <= state_w;
		i_dat_r <= i_dat_w;
		oe_r <= oe_w;
		o_sdat_r <= o_sdat_w;
		byte_counter_r <= byte_counter_w;
		bit_counter_r <= bit_counter_w;
		clk_counter_r <= clk_counter_w;

	end
end
endmodule