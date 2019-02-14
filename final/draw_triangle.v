module draw_triangle(
	input clk, rst,
	input draw_enable,      // enable signal when two positions needed have been read, only 1 cycle
	input renew_output,     // tell the draw_triangle it can transmit the next output position, only 1 cycle
	input end_frame,        // only 1 cycle
	// input [3:0] point_size,    // can have different size
	// input [9:0] X_MAX,         // X MAX address
	input [9:0] i_X_pos_1, // 1st position
	input [9:0] i_Y_pos_1, // 1st position
	input [9:0] i_X_pos_2, // 2nd position
	input [9:0] i_Y_pos_2, // 2nd position
	output reg [9:0] o_X_pos,
	output reg [9:0] o_Y_pos,
	output done         // done = 1 if the last position to be drawn has been outputted 
);

parameter point_size = 10'd2; // 3 x 3 rectangle
parameter X_MAX = 10'd799;
parameter Y_MAX = 10'd599;

reg [9:0] X_1_w, Y_1_w, X_2_w, Y_2_w; 
reg [9:0] X_1_r, Y_1_r, X_2_r, Y_2_r;

// output
reg done_r, done_w;
reg [9:0] o_X_pos_w, o_Y_pos_w;
reg [1:0] compare_w, compare;

assign done = (end_frame) ? 0 : done_r;

always @ (*) begin
	X_1_w   = (draw_enable) ? i_X_pos_1 : X_1_r;
	Y_1_w   = (draw_enable) ? i_Y_pos_1 : Y_1_r;
	X_2_w   = (draw_enable) ? i_X_pos_2 : X_2_r;
	Y_2_w   = (draw_enable) ? i_Y_pos_2 : Y_2_r;
end

reg  flip_w, flip_r; // to choose X_left or X_right
reg  [9:0] X_step;
reg  [3:0] size_w, size_r;
reg  [9:0] X_w, X_r, Y_w, Y_r;
reg  [9:0] X_compare_w, X_compare_r, Y_compare_w, Y_compare_r;
reg  [9:0] X_left_w, X_left_r, X_right_w, X_right_r;

wire [9:0] X_1_to_2 = X_1_r - X_2_r;
wire [9:0] X_2_to_1 = X_2_r - X_1_r;
wire [9:0] Y_1_to_2 = Y_1_r - Y_2_r;
wire [9:0] Y_2_to_1 = Y_2_r - Y_1_r;

always @ (*) begin
	if (Y_2_r >  Y_1_r) begin
		compare_w   = 0;
		Y_w         = Y_1_r;
		Y_compare_w = Y_2_r;
	end else if (Y_1_r >  Y_2_r) begin
		compare_w   = 1;
		Y_w         = Y_2_r;
		Y_compare_w = Y_1_r;
	end else if (Y_1_r == Y_2_r) begin
		compare_w   = 2;
		Y_w         = Y_2_r;
		Y_compare_w = Y_1_r;
	end else begin
		compare_w   = 3;
		Y_w         = (Y_1_r > Y_2_r) ? Y_2_r : Y_1_r;
		Y_compare_w = (Y_1_r > Y_2_r) ? Y_1_r : Y_2_r;
	end
	
	if ((Y_2_r >  Y_1_r) && (X_1_r >  X_2_r)) begin   // 1
			X_step      = ((X_1_to_2 / Y_2_to_1) > 0) ? (X_1_to_2 / Y_2_to_1) : 1;
			X_w         = X_1_r;
			X_compare_w = {10{((X_1_r << 1) > X_2_r)}} & ((X_1_r << 1) - X_2_r);
	end else if ((Y_2_r >  Y_1_r) && (X_2_r >  X_1_r)) begin   // 2
			X_step      = ((X_2_to_1 / Y_2_to_1) > 0) ? (X_2_to_1 / Y_2_to_1) : 1;
			X_w         = X_1_r;
			X_compare_w = X_2_r;
	end else if ((Y_1_r > Y_2_r) && (X_1_r > X_2_r)) begin              // 3
			X_step      = ((X_1_to_2 / Y_1_to_2) > 0) ? (X_1_to_2 / Y_1_to_2) : 1;
			X_w         = X_2_r;
			X_compare_w = X_1_r;
	end else if ((Y_1_r >  Y_2_r) && (X_2_r >  X_1_r)) begin   // 4
			X_step      = ((X_2_to_1 / Y_1_to_2) > 0) ? (X_2_to_1 / Y_1_to_2) : 1;
			X_w         = ((X_1_r << 1) > X_2_r) ? ((X_1_r << 1) - X_2_r) : 0;
			X_compare_w = X_1_r;
	end else if ((Y_1_r == Y_2_r) && (X_1_r >  X_2_r)) begin   // 5
			X_step      = 1;
			X_w         = X_2_r;
			X_compare_w = X_1_r;
	end else if ((Y_1_r == Y_2_r) && (X_2_r >  X_1_r)) begin   // 6
			X_step      = 1;
			X_w         = X_1_r;
			X_compare_w = X_2_r;
	end else if ((Y_1_r != Y_2_r) && (X_1_r == X_2_r)) begin   // 7
			X_step      = 0;
			X_w         = X_1_r;
			X_compare_w = X_1_r;
	end else begin                                             // 0
			X_step      = 0;
			X_w         = X_1_r;
			X_compare_w = X_1_r;
	end
end

always @ (*) begin
	case (compare)
		1 : begin
			if (end_frame) begin
				o_X_pos_w = X_r;
				o_Y_pos_w = Y_r;
				done_w    = 0;
				flip_w    = 1;
				size_w    = 0;
				X_left_w  = X_r; 
				X_right_w = X_compare_r;
			end else begin
				done_w = (((o_X_pos == X_compare_r) && (o_Y_pos == Y_compare_r)) || (X_left_r > X_right_r));
				if (renew_output) begin
					o_Y_pos_w = ((o_X_pos < X_right_r) || (o_Y_pos == Y_compare_r)) ? o_Y_pos : (o_Y_pos + 1);
					if ((((X_right_r - X_left_r) < (point_size << 1) + 2) && (o_Y_pos < Y_compare_r)) || (o_Y_pos == Y_r)) begin
						o_X_pos_w = (o_X_pos < X_right_r) ? (o_X_pos + 1) : (((X_left_r + X_step) < X_MAX) ? (X_left_r + X_step) : X_MAX);
						size_w    = 0;
						flip_w    = 1;
						if (X_step > point_size) begin 
							X_left_w  = (o_X_pos < X_right_r) ? X_left_r : (((X_left_r + X_step + point_size) < X_MAX) ? (X_left_r + X_step + point_size) : X_MAX);
							X_right_w = (o_X_pos < X_right_r) ? X_right_r : ({10{(X_right_r >  (X_step + point_size))}} & (X_right_r - X_step - point_size));	
						end else begin
							X_left_w  = (o_X_pos < X_right_r) ? X_left_r : (((X_left_r + X_step) < X_MAX) ? (X_left_r + X_step) : X_MAX);
							X_right_w = (o_X_pos < X_right_r) ? X_right_r : ({10{(X_right_r >  X_step)}} & (X_right_r - X_step));	
						end
					end else if (o_Y_pos == Y_compare_r) begin
						o_X_pos_w = X_compare_r;
						size_w    = 0;
						flip_w    = 1;		
						X_left_w  = X_left_r;
						X_right_w = X_right_r;	
					end else begin	
						if (X_step > point_size) begin
							size_w    = (size_r < (X_step - point_size)) ? (size_r + 1) : 0;
							if (flip_r) begin // renew X_left
								o_X_pos_w = (size_r < (X_step - point_size)) ? (o_X_pos + 1) : ((X_right_r > point_size) ? (X_right_r - point_size) : 0);
								X_left_w  = X_left_r;
								X_right_w = X_right_r;
								flip_w    = (size_r < (X_step - point_size));
							end else begin    // renew X_right
								o_X_pos_w = (size_r < (X_step - point_size)) ? (o_X_pos + 1) : (((X_left_r + X_step) < X_MAX) ? (X_left_r + X_step) : X_MAX);
								X_left_w  = (size_r < (X_step - point_size)) ? X_left_r : (((X_left_r + X_step) < X_MAX) ? (X_left_r + X_step) : X_MAX);
								X_right_w = (size_r < (X_step - point_size)) ? X_right_r : ({10{(X_right_r >  X_step)}} & (X_right_r - X_step));
								flip_w    = ~(size_r < (X_step - point_size));
							end
						end else begin
							size_w    = (size_r < point_size) ? (size_r + 1) : 0;
							if (flip_r) begin // renew X_left
								o_X_pos_w = (size_r < point_size) ? (o_X_pos + 1) : ((X_right_r > point_size) ? (X_right_r - point_size) : 0);
								X_left_w  = X_left_r;
								X_right_w = X_right_r;
								flip_w    = (size_r < point_size);
							end else begin    // renew X_right
								o_X_pos_w = (size_r < point_size) ? (o_X_pos + 1) : (((X_left_r + X_step) < X_MAX) ? (X_left_r + X_step) : X_MAX);
								X_left_w  = (size_r < point_size) ? X_left_r : (((X_left_r + X_step) < X_MAX) ? (X_left_r + X_step) : X_MAX);
								X_right_w = (size_r < point_size) ? X_right_r : ((X_right_r >  X_step) ? (X_right_r - X_step) : 0);
								flip_w    = ~(size_r < point_size);
							end
						end
					end
				end else begin
					size_w    = size_r;
					flip_w    = flip_r;
					X_left_w  = X_left_r;
					X_right_w = X_right_r;
					o_X_pos_w = o_X_pos;	
					o_Y_pos_w = o_Y_pos;
				end
			end
		end
		2 : begin
			flip_w    = 0;
			size_w    = 0;
			X_left_w  = X_left_r;
			X_right_w = X_compare_r;
			done_w    = ((o_X_pos == X_compare_r) && (o_X_pos < X_MAX));
			if (end_frame) begin
				o_X_pos_w = X_r;
				o_Y_pos_w = Y_r;
			end else begin
				o_Y_pos_w = o_Y_pos;
				o_X_pos_w = (renew_output && (o_X_pos < X_compare_r) && (o_X_pos < X_MAX)) ? (o_X_pos + 1) : o_X_pos;
			end
		end
		3 : begin
			flip_w    = 0;
			X_left_w  = X_left_r;
			X_right_w = X_right_r;
			size_w    = 0;
			done_w    = ((o_Y_pos == Y_compare_r) && (o_Y_pos < Y_MAX));
			if (end_frame) begin
				o_X_pos_w = X_r;
				o_Y_pos_w = Y_r;
			end else begin
				o_X_pos_w = X_r;
				o_Y_pos_w = (renew_output && (o_Y_pos < Y_compare_r) && (o_Y_pos < Y_MAX)) ? (o_Y_pos + 1) : o_Y_pos;
			end
		end
		default : begin
			if (end_frame) begin
				o_X_pos_w = X_r;
				o_Y_pos_w = Y_r;
				size_w    = 0;
				flip_w    = 1;
				done_w    = 0;
				X_left_w  = ({16{(X_r > X_step)}} & (X_r - X_step)); 
				X_right_w = ((X_r + X_step) < X_MAX) ? (X_r + X_step) : X_MAX; 
			end else begin
				done_w = (((o_X_pos == X_right_r) && (o_Y_pos == Y_compare_r)) || (X_left_r > X_right_r));
				if (renew_output) begin
					if (((X_right_r - X_left_r) > (point_size << 1) + 2) && (o_Y_pos < Y_compare_r) && (o_Y_pos > Y_r)) begin
						if (X_step > point_size) begin
							size_w    = (size_r < (X_step - point_size)) ? (size_r + 1) : 0;
							flip_w    = (size_r < (X_step - point_size)) ? flip_r : !flip_r;
							o_Y_pos_w = (!flip_r && (size_r == (X_step - point_size))) ? (o_Y_pos + 1) : o_Y_pos;
							if (flip_r) begin // renew X_left
								o_X_pos_w = (size_r < (X_step - point_size)) ? (o_X_pos + 1) : (X_right_r - point_size);
								X_left_w  = X_left_r;
								X_right_w = X_right_r;
							end else begin    // renew X_right
								o_X_pos_w = (size_r < (X_step - point_size)) ? (o_X_pos + 1) : ({16{(X_left_r > X_step)}} & (X_left_r - X_step));
								X_left_w  = (size_r < (X_step - point_size)) ? X_left_r : ({16{(X_left_r > X_step)}} & (X_left_r - X_step));
								X_right_w = (size_r < (X_step - point_size)) ? X_right_r : ((X_right_r + X_step) < X_MAX) ? (X_right_r + X_step) : X_MAX;
							end
						end else begin
							size_w    = (size_r < point_size) ? (size_r + 1) : 0;
							flip_w    = (size_r < point_size) ? flip_r : !flip_r;
							o_Y_pos_w = (!flip_r && (size_r == point_size)) ? (o_Y_pos + 1) : o_Y_pos;
							if (flip_r) begin // renew X_left
								o_X_pos_w = (size_r < point_size) ? (o_X_pos + 1) : (X_right_r - point_size);
								X_left_w  = X_left_r;
								X_right_w = X_right_r;
							end else begin    // renew X_right
								o_X_pos_w = (size_r < point_size) ? (o_X_pos + 1) : ({16{(X_left_r > X_step)}} & (X_left_r - X_step));
								X_left_w  = (size_r < point_size) ? X_left_r : ({16{(X_left_r > X_step)}} & (X_left_r - X_step));
								X_right_w = (size_r < point_size) ? X_right_r : ((X_right_r + X_step) < X_MAX) ? (X_right_r + X_step) : X_MAX;
							end
						end
					end else if (o_Y_pos == Y_r) begin
						size_w    = 0;
						flip_w    = 1;
						o_X_pos_w = X_left_r;
						o_Y_pos_w = o_Y_pos + 1;
						X_left_w  = X_left_r;
						X_right_w = X_right_r;
					end else begin
						size_w    = 0;
						flip_w    = 1;
						o_X_pos_w = (o_X_pos < X_right_r) ? (o_X_pos + 1) : (X_left_r > X_step) ? (X_left_r - X_step) : 0;
						o_Y_pos_w = (o_X_pos < X_right_r) ? o_Y_pos : (o_Y_pos + 1);
						if (X_step > point_size) begin
							X_left_w  = (o_X_pos < X_right_r) ? X_left_r : ({10{(X_left_r > (X_step + point_size))}} & (X_left_r - X_step - point_size));
							X_right_w = (o_X_pos < X_right_r) ? X_right_r : ((X_right_r + X_step + point_size) < X_MAX) ? (X_right_r + X_step + point_size) : X_MAX;
						end else begin
							X_left_w  = (o_X_pos < X_right_r) ? X_left_r : ({10{(X_left_r > X_step)}} & (X_left_r - X_step));
							X_right_w = (o_X_pos < X_right_r) ? X_right_r : ((X_right_r + X_step) < X_MAX) ? (X_right_r + X_step) : X_MAX;
						end
					end
				end else begin
					size_w    = size_r;
					flip_w    = flip_r;
					o_X_pos_w = o_X_pos;	
					o_Y_pos_w = o_Y_pos;	
					X_left_w  = X_left_r;
					X_right_w = X_right_r;
					done_w    = done_r;
				end	
			end
		end
	endcase
end

always @ (posedge clk) begin
	if (!rst) begin
		o_X_pos     <= 0;
		o_Y_pos     <= 0;
		X_left_r    <= 0;
		X_right_r   <= 0;
		flip_r      <= 1'd0;
		size_r      <= 0;
		X_r         <= 0;
		Y_r         <= 0;
		X_1_r       <= 0;
		Y_1_r       <= 0;
		X_2_r       <= 0;
		Y_2_r       <= 0;
		done_r      <= 1'd0;
		X_compare_r <= 0;
		Y_compare_r <= 0;
		compare     <= 0;
	end else begin
		o_X_pos     <= o_X_pos_w;
		o_Y_pos     <= o_Y_pos_w;
		X_left_r    <= X_left_w;
		X_right_r   <= X_right_w;
		flip_r      <= flip_w;
		size_r      <= size_w;
		X_r         <= X_w;
		Y_r         <= Y_w;
		X_1_r       <= X_1_w;
		Y_1_r       <= Y_1_w;
		X_2_r       <= X_2_w;
		Y_2_r       <= Y_2_w;
		done_r      <= done_w;
		X_compare_r <= X_compare_w;
		Y_compare_r <= Y_compare_w;
		compare     <= compare_w;
	end
end
endmodule