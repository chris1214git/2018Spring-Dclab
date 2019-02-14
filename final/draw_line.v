module draw_line(
	input clk, rst,
	input draw_line_enable, // enable signal when two positions needed to be connected have been read, only 1 cycle
	input renew_output,     // tell the draw_line it can transmit the next output position to be drawn, only 1 cycle
	input end_frame,        // only 1 cycle
	input different_line,
	// input [3:0] point_size,    // can have different size
	input [9:0] i_X_pos_1, // 1st position
	input [9:0] i_Y_pos_1, // 1st position
	input [9:0] i_X_pos_2, // 2nd position
	input [9:0] i_Y_pos_2, // 2nd position
	output reg [9:0] o_X_pos,
	output reg [9:0] o_Y_pos,
	output reg done         // done = 1 if the last position to be drawn has been outputted 
);

parameter point_size = 4'd2; // 3 x 3 rectangle
parameter X_MAX = 10'd799;
parameter Y_MAX = 10'd599;
parameter X_point_MAX = X_MAX - {6'd0, point_size} - 1;

reg  renew, done_w, end_frame_r, end_frame_r_r;
wire detect_done;
reg  [3:0] size_w, size_r;
reg  [9:0] X_pos_r, Y_pos_r, o_X_pos_w, o_Y_pos_w;  
wire [9:0] X_pos, Y_pos;

draw_line_dectect dectect_line ( .clk(clk), .rst(rst), .draw_line_enable(draw_line_enable), 
                                 .renew_output(renew), .end_frame(end_frame), .different_line(different_line), .point_size(point_size), 
	                             .i_X_pos_1(i_X_pos_1), .i_Y_pos_1(i_Y_pos_1), .i_X_pos_2(i_X_pos_2), .i_Y_pos_2(i_Y_pos_2), 
	                             .o_X_pos(X_pos), .o_Y_pos(Y_pos), .done(detect_done) );

always @ (*) begin
	if (done) begin
		done_w = ~(end_frame_r_r);
	end else begin
		done_w = (detect_done && (size_r == point_size));
	end
	renew = (renew_output && !detect_done && (size_r == 0));
	
	if (renew_output) begin
		size_w  = (size_r < point_size) ? (size_r + 1) : 0;
	end else begin
		size_w  = (end_frame_r_r) ? 1 : size_r;
	end
	if (end_frame_r_r) begin
		o_X_pos_w = (X_pos_r < X_point_MAX) ? X_pos : X_point_MAX;
		o_Y_pos_w = Y_pos;
	end else begin
		if (renew_output && !detect_done && (size_r == 0)) begin
			o_X_pos_w = (X_pos < X_point_MAX) ? X_pos : X_point_MAX;
			o_Y_pos_w = Y_pos;
		end else begin
			o_X_pos_w = (renew_output) ? (o_X_pos + 1) : o_X_pos;
			o_Y_pos_w = o_Y_pos;
		end
	end
end



always@(posedge clk) begin
	if (!rst) begin
		X_pos_r       <= 0;
		Y_pos_r       <= 0;
		o_X_pos       <= 0;
		o_Y_pos       <= 0;
		size_r        <= 0;
		done          <= 0;
		end_frame_r   <= 0;
		end_frame_r_r <= 0;
	end else begin
		X_pos_r       <= X_pos;
		Y_pos_r       <= Y_pos;
		o_X_pos       <= o_X_pos_w;
		o_Y_pos       <= o_Y_pos_w;
		size_r        <= size_w;
		done          <= done_w;
		end_frame_r   <= end_frame;
		end_frame_r_r <= end_frame_r;
	end
end	
	
endmodule