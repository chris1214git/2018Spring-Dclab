module draw_line_dectect(
	input clk, rst,
	input draw_line_enable, // enable signal when two positions needed to be connected have been read, only 1 cycle
	input renew_output,     // tell the draw_line it can transmit the next output position to be drawn, only 1 cycle
	input end_frame,        // only 1 cycle
	input different_line,
	input [3:0] point_size,
	input [9:0] i_X_pos_1, // 1st position
	input [9:0] i_Y_pos_1, // 1st position 
	input [9:0] i_X_pos_2, // 2nd position 
	input [9:0] i_Y_pos_2, // 2nd position
	output reg [9:0] o_X_pos,
	output reg [9:0] o_Y_pos,
	output reg done         // done = 1 if the last position to be drawn has been outputted 
);

parameter X_MAX = 10'd799;
parameter Y_MAX = 10'd599;
parameter X_MAX_fin = 10'd800;
parameter Y_MAX_fin = 10'd600;

// output
reg  [9:0] o_X_pos_r, o_Y_pos_r;
reg  check, check_r;
// stores
reg  [9:0] X_last_r, Y_last_r, X_last_w, Y_last_w;
reg  different_line_w, different_line_r, end_frame_r;
// group 0
reg  [9:0] X1_w, Y1_w, X2_w, Y2_w; 
reg  [9:0] X1_r, Y1_r, X2_r, Y2_r;
// group 1
reg  [9:0] X_in1_w, Y_in1_w, X_in2_w, Y_in2_w;
reg  [9:0] X_in1_r, Y_in1_r, X_in2_r, Y_in2_r;

// calculate
reg  Y_step;
reg  [3:0] count_w, count_r, count_max;
reg  [9:0] X_step;
reg  [9:0] X_w, X_r, Y_w, Y_r;
wire [9:0] X_1_to_2, X_2_to_1, Y_1_to_2, Y_2_to_1;

assign X_1_to_2 = X1_r - X2_r;
assign X_2_to_1 = X2_r - X1_r;
assign Y_1_to_2 = Y1_r - Y2_r;
assign Y_2_to_1 = Y2_r - Y1_r;

always @ (*) begin
	X_in1_w = (draw_line_enable) ? i_X_pos_1 : X_in1_r;
	Y_in1_w = (draw_line_enable) ? i_Y_pos_1 : Y_in1_r;
	X_in2_w = (draw_line_enable) ? i_X_pos_2 : X_in2_r;
	Y_in2_w = (draw_line_enable) ? i_Y_pos_2 : Y_in2_r;
end

reg check_different_line_w, check_different_line_r;

always @ (*) begin
	if (end_frame) begin
		X1_w  = (X_last_r > X_MAX) ? (X_in1_r) : X_last_r;
		Y1_w  = (X_last_r > X_MAX) ? (Y_in1_r) : Y_last_r;
	end else begin
		X1_w  = X1_r;
		Y1_w  = Y1_r;
	end
	
	X2_w  = (end_frame) ? X_in2_r : X2_r;
	Y2_w  = (end_frame) ? Y_in2_r : Y2_r;
	
	if (check_different_line_r) begin
		check_different_line_w = (draw_line_enable) ? 0 : check_different_line_r;
	end else begin
		check_different_line_w = different_line;
	end
	different_line_w = (end_frame) ? check_different_line_w : different_line_r;
	if (different_line_r) begin
		X_last_w = X_MAX_fin;
		Y_last_w = Y_MAX_fin;
	end else begin
		X_last_w = (Y2_r >= Y1_r) ? o_X_pos_r : X2_r;
		Y_last_w = (Y2_r >= Y1_r) ? o_Y_pos_r : Y2_r;
	end
end

reg [2:0] compare, compare_r; 

always @(*) begin
	if (end_frame) begin
		if ((X1_w > X2_w) && (Y1_w >= Y2_w)) compare = 3'd1;
		else if ((X1_w >  X2_w) && (Y2_w >  Y1_w)) compare = 3'd2;
		else if ((X2_w >  X1_w) && (Y2_w >= Y1_w)) compare = 3'd1; 
		else if ((X2_w >  X1_w) && (Y1_w >  Y2_w)) compare = 3'd2;
		else if ((X1_w == X2_w) && (Y1_w != Y2_w)) compare = 3'd3;
		else compare = 3'd0;
	end else begin
		compare = compare_r;
	end
end

always @(*) begin
	count_max = ((Y1_r == Y2_r) || (X_step[4:0] < ({1'd0, point_size} + 5'd2))) ? 4'd0 : (((X_step / (point_size + 1)) > 1) ? ((X_step / (point_size + 1)) - 1) : 4'd0);
	if (renew_output) 
			count_w = (count_r < count_max) ? (count_r + 4'd1) : 4'd0;
	else 
			count_w = count_r;
	if (compare_r == 3'd1)
		Y_step = (Y1_r > Y2_r) ? (Y1_r > Y2_r) : (Y2_r > Y1_r);
	else
		Y_step = 1'd1;

	case (compare_r) 
		3'd1 : begin
			check  = check_r;
			if (Y1_r > Y2_r) begin 
				if ((X_1_to_2 / Y_1_to_2) > 0) X_step = X_1_to_2 / Y_1_to_2;
				else X_step = {9'd0, (Y_1_to_2 > (point_size + 1))};
			end else if (Y1_r < Y2_r) begin
				if ((X_2_to_1 / Y_2_to_1) > 0) X_step = X_2_to_1 / Y_2_to_1;
				else X_step = {9'd0, (Y_2_to_1 > (point_size + 1))};
			end else begin 
				X_step = {5'd0, (point_size + 5'd1)};
			end 
			if (end_frame_r) begin
				o_Y_pos = (Y1_r > Y2_r) ? Y2_r : Y1_r;
				Y_w     = (Y1_r > Y2_r) ? Y1_r : Y2_r;
				done    = 1'd0;
				
				if (Y1_r > Y2_r) begin
					o_X_pos = ({10{(X1_r > (X_step * Y_1_to_2))}} & (X1_r - (X_step * Y_1_to_2)));	
					X_w     = X1_r;
				/*end else if (Y1_r == Y2_r) begin
					o_X_pos = (X1_r > X2_r) ? X2_r : X1_r;
					X_w     = (X1_r > X2_r) ? X1_r : X2_r;*/
				end else begin 
					o_X_pos = X1_r;
					X_w     = X2_r;
				end
			end else begin 
				X_w     = X_r;
				Y_w     = Y_r;
				o_Y_pos = ((count_r == count_max) && renew_output) ? (o_Y_pos_r + Y_step) : o_Y_pos_r;
				
				if (count_max > 0) begin
					if (renew_output) 
						o_X_pos = (count_r < count_max) ? (o_X_pos_r + point_size + 1) : ({10{(o_X_pos_r > 1)}} & (o_X_pos_r - 1));
					else 
						o_X_pos = o_X_pos_r;
				end else begin 
					o_X_pos = (renew_output) ? (o_X_pos_r + X_step) : o_X_pos_r;
				end
				if (Y1_r == Y2_r) begin
					done    = ~(o_X_pos_r < X_r);
				end else begin
					done    = ~(o_Y_pos_r < Y_r);
			 	end
			end
		end
		3'd2 : begin
			X_step = (Y1_r < Y2_r) ? (X_1_to_2 / Y_2_to_1) : (X_2_to_1 / Y_1_to_2);
			check  = check_r;
			done   = ~(end_frame_r || (o_Y_pos_r < Y_r));
			if (end_frame_r) begin
				if ((Y1_r < Y2_r) || ((X_2_to_1 / Y_1_to_2) == 0)) begin
					o_X_pos = X1_r;
					X_w     = X2_r;
				end else begin
					o_X_pos = ((X1_r + (X_step * Y_1_to_2)) < X_MAX) ? (X1_r + (X_step * Y_1_to_2)) : X_MAX;
					X_w     = X1_r;
				end
				o_Y_pos = (Y1_r < Y2_r) ? Y1_r : Y2_r;
				Y_w     = (Y1_r < Y2_r) ? Y2_r : Y1_r;
			end else begin
				o_Y_pos = ((count_r == count_max) && renew_output) ? (o_Y_pos_r + Y_step) : o_Y_pos_r;
				if ((count_max > 0) && (count_r < count_max)) begin
					if (renew_output) begin
						o_X_pos = (count_r == 0) ? ({10{(o_X_pos_r > (count_max * (point_size + 1)))}} & (o_X_pos_r - (count_max * (point_size + 1)))) : (o_X_pos_r + point_size + 1);	
					end else 
						o_X_pos = o_X_pos_r;
				end else begin 
					o_X_pos = (renew_output) ? ({10{(o_X_pos_r > X_step)}} & (o_X_pos_r - X_step)) : o_X_pos_r;
				end
				X_w     = X_r;
				Y_w     = Y_r;
			end
		end
		3'd3 : begin
			X_step = 0;
			check  = check_r;
			done   = ~(end_frame_r || (o_Y_pos_r < Y_r));
			if (end_frame_r) begin
				o_X_pos = (Y1_r > Y2_r) ? X2_r : X1_r;
				o_Y_pos = (Y1_r > Y2_r) ? Y2_r : Y1_r;
				X_w     = (Y1_r > Y2_r) ? X1_r : X2_r;
				Y_w     = (Y1_r > Y2_r) ? Y1_r : Y2_r;
			end else begin
				o_X_pos = o_X_pos_r;
				o_Y_pos = (renew_output) ? (o_Y_pos_r + Y_step) : o_Y_pos_r;
				X_w     = X_r;
				Y_w     = Y_r;
			end
		end
		default : begin
			X_step  = 0;
			check   = (renew_output || end_frame_r) ? renew_output : check_r;
			o_X_pos = X1_w;
			o_Y_pos = Y1_w;
			X_w     = X_r;
			Y_w     = Y_r;
			done    = check_r;
		end
	endcase
end

always@(posedge clk) begin
	if (!rst) begin
		o_X_pos_r        <= 10'd0;
		o_Y_pos_r        <= 10'd0;
		check_r          <= 1'd0;
		count_r          <= 0;
		X_r              <= 10'd0;
		Y_r              <= 10'd0;
		X1_r             <= X_MAX_fin;
		Y1_r             <= Y_MAX_fin;
		X2_r             <= X_MAX_fin;
		Y2_r             <= Y_MAX_fin;
		X_in1_r          <= X_MAX_fin;
		Y_in1_r          <= Y_MAX_fin;
		X_in2_r          <= X_MAX_fin;
		Y_in2_r          <= Y_MAX_fin;
		X_last_r         <= X_MAX_fin;
		Y_last_r         <= Y_MAX_fin;
		end_frame_r      <= 1'd0;
		different_line_r <= 1'd1;
		compare_r        <= 0;
		check_different_line_r <= 1;
	end else begin
		o_X_pos_r        <= o_X_pos;
		o_Y_pos_r        <= o_Y_pos;
		check_r          <= check;
		count_r          <= count_w;
		X_r              <= X_w;
		Y_r              <= Y_w;
		X1_r             <= X1_w;
		Y1_r             <= Y1_w;
		X2_r             <= X2_w;
		Y2_r             <= Y2_w;
		X_in1_r          <= X_in1_w;
		Y_in1_r          <= Y_in1_w;
		X_in2_r          <= X_in2_w;
		Y_in2_r          <= Y_in2_w;
		X_last_r         <= X_last_w;
		Y_last_r         <= Y_last_w;
		end_frame_r      <= end_frame;
		different_line_r <= different_line_w;
		compare_r        <= compare;
		check_different_line_r <= check_different_line_w;
	end
end

endmodule
