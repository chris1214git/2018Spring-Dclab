module rectangle (
	clk,
	rst,
	i_x_pos,
	i_y_pos,
	rec_start,  // rec_start = 1 if the first point is inputted 
	enable,    // enable = 1 if two positions are sent (start to draw the rectangle)
	strat_to_output, // tell RECTANGLE it can start to send the output o_x_pos & o_y_pos
	renew_start,  // renew_start = 1 if the output position sent by the rectangle has been saved into the SDRAM
	new_frame,
	all_done,     // all_done = 1 if all the positions have been outputted
	o_x_pos,
	o_y_pos
);
	input clk, rst;
	input [15:0] i_x_pos;
	input [15:0] i_y_pos;
	input rec_start;
	input enable;
	input strat_to_output;
	input renew_start;
	input new_frame;
	output all_done;
	output [15:0] o_x_pos;
	output [15:0] o_y_pos;
	
	localparam width = 3;
	
	localparam LURD = 0;        // LEFT UP TO RIGHT DOWN
	localparam LDRU = 1;		// LEFT DOWN TO RIGHT UP 
	localparam RDLU = 2;		// RIGHT DOWN TO LEFT UP
	localparam RULD = 3;		// RIGHT UP TO LEFT DOWN
	
	// 1st input position
	reg [15:0] x1_w, y1_w;
	reg [15:0] x1_r, y1_r;
	
	// 2nd input position
	reg [15:0] x2_w, y2_w;
	reg [15:0] x2_r, y2_r;
	
	// output position
	reg [15:0] o_x_w, o_x_r;
	reg [15:0] o_y_w, o_y_r;
	
	// the current state
	reg [1:0] state_w, state_r;
	
	reg done_w, done_r;
	
	assign o_x_pos = o_x_r;
	assign o_y_pos = o_y_r;
	assign all_done = done_r;
	
	
	always@ (*) begin
		/*o_x_w = o_x_r;
		o_y_w = o_y_r;*/
		x1_w = x1_r;
		y1_w = y1_r;
		x2_w = x2_r;
		y2_w = y2_r;
		if (rec_start==1) begin
			x1_w = i_x_pos;
			y1_w = i_y_pos;
			/*o_x_w = i_x_pos;	// the first point
			o_y_w = i_y_pos;	// the first point
			*/
		end
		else begin
			x1_w = x1_r;
			y1_w = y1_r;
		end
		if (enable==1) begin
			x2_w = i_x_pos;
			y2_w = i_y_pos;
		end
		else begin
			x2_w = x2_r;
			y2_w = y2_r;
		end
		
		// to determine the current state
		if(enable == 1) begin
			if ((x1_w < x2_w) && (y1_w < y2_w)) state_w = LURD;
			else if ((x1_w < x2_w) && (y1_w > y2_w)) state_w = LDRU;
			else if ((x1_w > x2_w) && (y1_w > y2_w)) state_w = RDLU;
			else state_w = RULD;
		end
		else state_w = state_r;
	end
	
	always@ (*) begin
		if (strat_to_output==1) begin
			if(state_w == LURD) begin
				o_x_w = x1_r;	// the first point
				o_y_w = y1_r;	// the first point
			end
			else if(state_w == LDRU) begin
				o_x_w = x1_r;
				o_y_w = y2_r;
			end
			else if(state_w == RDLU) begin
				o_x_w = x2_r;
				o_y_w = y2_r;
			end
			else begin
				o_x_w = x2_r;
				o_y_w = y1_r;
			end
		end
		else if(done_r == 1 && new_frame == 1) begin
			o_x_w = 801;
			o_y_w = 601;
		end
		else begin
			o_x_w = o_x_r;
			o_y_w = o_y_r;
		end
		case (state_r)
			LURD : begin
				if(renew_start == 1 && done_r != 1) begin
					if((o_x_r >= x1_r) && (o_x_r < x2_r) && (o_y_r >= y1_r) && (o_y_r < (y1_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r == x2_r) && (o_y_r >= y1_r) && (o_y_r < (y2_r + width - 1))) begin
						o_x_w = x1_r;
						o_y_w = o_y_r + 1;
					end
					else if ((o_x_r >= x1_r) && (o_x_r < (x1_r + width - 1)) && (o_y_r < y2_r) && (o_y_r >= (y1_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if((o_x_r == (x1_r + width - 1)) && (o_y_r < y2_r) && (o_y_r >= (y1_r + width))) begin
						o_x_w = x2_r - width + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r < x2_r) && (o_x_r > (x2_r - width)) && (o_y_r < y2_r) && (o_y_r >= (y1_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r >= x1_r) && (o_x_r < x2_r) && (o_y_r >= y2_r) && (o_y_r < y2_r + width)) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else begin
						o_x_w = o_x_r;
						o_y_w = o_y_r;
					end
				end
				else;
			end
			LDRU : begin
				if(renew_start == 1 && done_r != 1) begin
					if((o_x_r >= x1_r) && (o_x_r < x2_r) && (o_y_r >= y2_r) && (o_y_r < (y2_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r == x2_r) && (o_y_r >= y2_r) && (o_y_r < (y1_r + width - 1))) begin
						o_x_w = x1_r;
						o_y_w = o_y_r + 1;
					end
					else if ((o_x_r >= x1_r) && (o_x_r < (x1_r + width - 1)) && (o_y_r < y1_r) && (o_y_r >= (y2_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if((o_x_r == (x1_r + width - 1)) && (o_y_r < y1_r) && (o_y_r >= (y2_r + width))) begin
						o_x_w = x2_r - width + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r < x2_r) && (o_x_r > (x2_r - width)) && (o_y_r < y1_r) && (o_y_r >= (y2_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r >= x1_r) && (o_x_r < x2_r) && (o_y_r >= y1_r) && (o_y_r < y1_r + width)) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else begin
						o_x_w = o_x_r;
						o_y_w = o_y_r;
					end
				end
				else;
			end
			RDLU : begin
				if(renew_start == 1 && done_r != 1) begin
					if((o_x_r >= x2_r) && (o_x_r < x1_r) && (o_y_r >= y2_r) && (o_y_r < (y2_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r == x1_r) && (o_y_r >= y2_r) && (o_y_r < (y1_r + width - 1))) begin
						o_x_w = x2_r;
						o_y_w = o_y_r + 1;
					end
					else if ((o_x_r >= x2_r) && (o_x_r < (x2_r + width - 1)) && (o_y_r < y1_r) && (o_y_r >= (y2_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r == (x2_r + width - 1)) && (o_y_r < y1_r) && (o_y_r >= (y2_r + width))) begin
						o_x_w = x1_r - width + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r < x1_r) && (o_x_r > (x1_r - width)) && (o_y_r < y1_r) && (o_y_r >= (y2_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r >= x2_r) && (o_x_r < x1_r) && (o_y_r >= y1_r) && (o_y_r < y1_r + width)) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else begin
						o_x_w = o_x_r;
						o_y_w = o_y_r;
					end
				end
				else;
			end
			RULD : begin
				if(renew_start == 1 && done_r != 1) begin
					if((o_x_r >= x2_r) && (o_x_r < x1_r) && (o_y_r >= y1_r) && (o_y_r < (y1_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r == x1_r) && (o_y_r >= y1_r) && (o_y_r < (y2_r + width - 1))) begin
						o_x_w = x2_r;
						o_y_w = o_y_r + 1;
					end
					else if ((o_x_r >= x2_r) && (o_x_r < (x2_r + width - 1)) && (o_y_r < y2_r) && (o_y_r >= (y1_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r == (x2_r + width - 1)) && (o_y_r < y2_r) && (o_y_r >= (y1_r + width))) begin
						o_x_w = x1_r - width + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r < x1_r) && (o_x_r > (x1_r - width)) && (o_y_r < y2_r) && (o_y_r >= (y1_r + width))) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else if ((o_x_r >= x2_r) && (o_x_r < x1_r) && (o_y_r >= y2_r) && (o_y_r < y2_r + width)) begin
						o_x_w = o_x_r + 1;
						o_y_w = o_y_r;
					end
					else begin
						o_x_w = o_x_r;
						o_y_w = o_y_r;
					end
				end
				else;
			end
		endcase
	end
	always@ (*) begin
		if(rec_start == 1) done_w = 0;
		else if ((state_r == LURD) && (o_x_r == x2_r) && (o_y_r == (y2_r + width - 1))) done_w = 1;
		else if ((state_r == LDRU) && (o_x_r == x2_r) && (o_y_r == (y1_r + width - 1))) done_w = 1;
		else if ((state_r == RDLU) && (o_x_r == x1_r) && (o_y_r == (y1_r + width - 1))) done_w = 1;
		else if ((state_r == RULD) && (o_x_r == x1_r) && (o_y_r == (y2_r + width - 1))) done_w = 1;
		else done_w = done_r;
	end
	
	always@ (posedge clk) begin
		if(!rst) begin
			x1_r <= 0;
			y1_r <= 0;
			x2_r <= 0;
			y2_r <= 0;
			o_x_r <= 801;
			o_y_r <= 601;
			done_r <= 0;
			state_r <= LURD;
		end
		else begin
			x1_r <= x1_w;
			y1_r <= y1_w;
			x2_r <= x2_w;
			y2_r <= y2_w;
			o_x_r <= o_x_w;
			o_y_r <= o_y_w;
			done_r <= done_w;
			state_r <= state_w;
		end
	end
	
	
endmodule