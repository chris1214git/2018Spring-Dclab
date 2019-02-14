module control_triangle(
	input clk_read,		// VGA clock for detect, draw_line and others
	input clk_write,    // VGA_BAR clock for control
	input rst,
	input [9:0] i_sCCD_R,
	input [9:0] i_sCCD_G,
	input [9:0] i_sCCD_B,
	input [15:0] i_X_Cont,
	input [15:0] i_Y_Cont,
	input [2:0] mode,
	
	output match_tri    // tell the output the input positions i_X_Cont & i_Y_Cont are matched with the rectangle output points x_pos_rec & y_pos_rec
);

	localparam DRAW_LINE = 3'd0;
	localparam RECTANGLE = 3'd1;
	localparam TRIANGLE = 3'd2;
	
	localparam INTERVAL = 7'd100;
	localparam X_LAST_POINT = 799;
	localparam Y_LAST_POINT = 599;
	
	// detect module
	wire detect;
	wire [15:0] x_pos_detect, y_pos_detect;
	
	//triangle module
	wire renew_tri;
	wire done_tri;
	wire [9:0] x_pos_tri, y_pos_tri;
	
	reg [1:0] point_count_w, point_count_r;
	reg tri_enable_w, tri_enable_r;
	
	reg [15:0] x_point1_w, x_point1_r;
	reg [15:0] y_point1_w, y_point1_r;
	reg [15:0] x_point2_w, x_point2_r;
	reg [15:0] y_point2_w, y_point2_r;
	
	// new and end frame processing
	reg end_frame_w, end_frame_r;
	reg flag_end_frame_w, flag_end_frame_r;
	wire new_frame_tri;
	
	// the interval of the 1st and 2nd point processing
	reg [9:0] interval_count_w, interval_count_r;
	// the interval of the current graph's 2nd point and the next graph's 1st point processing
	reg [9:0] done_count_w, done_count_r;
	
	
	
	assign new_frame_tri = (mode == TRIANGLE && i_X_Cont ==0 && i_Y_Cont==0);
	assign renew_tri = ((mode == TRIANGLE) && (x_pos_tri == i_X_Cont[9:0]) && (y_pos_tri == i_Y_Cont[9:0]) && (!done_tri));
	assign match_tri = ((mode == TRIANGLE) && (x_pos_tri == i_X_Cont[9:0]) && (y_pos_tri == i_Y_Cont[9:0]) && (done_count_r == 1));
	
	detect detect1(
		.clk(clk_read),
		.rst(rst),
		.i_R(i_sCCD_R),
		.i_G(i_sCCD_G),
		.i_B(i_sCCD_B),
		.i_X_pos(i_X_Cont),
		.i_Y_pos(i_Y_Cont),
		.new_frame(new_frame_tri),
		.end_frame(end_frame_r),
		.detect(detect),
		.o_X_pos(x_pos_detect),
		.o_Y_pos(y_pos_detect)
	);
	
	draw_triangle triangle1(
		.clk(clk_read),
		.rst(rst),
		.draw_enable(tri_enable_r),
		.renew_output(renew_tri),
		.end_frame(end_frame_r),
		.i_X_pos_1(x_point1_r[9:0]),
		.i_Y_pos_1(y_point1_r[9:0]),
		.i_X_pos_2(x_point2_r[9:0]),
		.i_Y_pos_2(y_point2_r[9:0]),
		.o_X_pos(x_pos_tri),
		.o_Y_pos(y_pos_tri),
		.done(done_tri)
	);
	
	always@ (*) begin
		x_point1_w = x_point1_r;
		y_point1_w = y_point1_r;
		x_point2_w = x_point2_r;
		y_point2_w = y_point2_r;
		point_count_w = point_count_r;
		tri_enable_w = tri_enable_r;
		
		if(mode == TRIANGLE) begin
			if(detect == 1 && point_count_r == 0) begin
				point_count_w = 1;
				x_point1_w = x_pos_detect;
				y_point1_w = y_pos_detect;
				tri_enable_w = 0;
			end
			else if(detect == 1 && point_count_r == 1 && interval_count_r == INTERVAL) begin
				point_count_w = 2;
				x_point2_w = x_pos_detect;
				y_point2_w = y_pos_detect;
				tri_enable_w = 1;
			end
			else if(done_count_r == INTERVAL) begin  // able to draw the next graph
				point_count_w = 0;
			end
			else begin
				tri_enable_w = 0;
			end
		end
		else ;
	end
	
	// interval count
	always@ (*) begin
		interval_count_w = interval_count_r;
		done_count_w = done_count_r;
		if(point_count_r == 1 && interval_count_r != INTERVAL) begin
			if(end_frame_r==1) interval_count_w = interval_count_r + 1;
			else interval_count_w = interval_count_r;
		end
		else if(point_count_r == 2 && done_count_r != INTERVAL) begin
			if(end_frame_r==1) done_count_w = done_count_r + 1;
			else done_count_w = done_count_r;
		end
		else if(done_count_r == INTERVAL) begin
			interval_count_w = 0;
			done_count_w = 0;
		end
		else;
	end
	always@ (*) begin
		end_frame_w = end_frame_r;
		flag_end_frame_w = flag_end_frame_r;
		if(i_X_Cont ==X_LAST_POINT && i_Y_Cont==Y_LAST_POINT && flag_end_frame_r != 1) begin
			end_frame_w = 1;
			flag_end_frame_w = 1;
		end
		else if(new_frame_tri==1) begin
			end_frame_w = 0;
			flag_end_frame_w = 0;
		end
		else begin
			end_frame_w = 0;
			flag_end_frame_w = flag_end_frame_r;
		end
	end
	
	always@ (posedge clk_write) begin
		if (!rst) begin
			point_count_r <= 0;
			tri_enable_r <= 0;
			x_point1_r <= 801;
	        y_point1_r <= 601;
	        x_point2_r <= 801;
	        y_point2_r <= 601;
			end_frame_r <= 0;
			flag_end_frame_r <= 0;
			interval_count_r <= 0;
			done_count_r <= 0;
		end
		else begin
			point_count_r <= point_count_w;
			tri_enable_r <= tri_enable_w;
			x_point1_r <= x_point1_w;
	        y_point1_r <= y_point1_w;
	        x_point2_r <= x_point2_w;
	        y_point2_r <= y_point2_w;
			end_frame_r <= end_frame_w;
			flag_end_frame_r <= flag_end_frame_w;
			interval_count_r <= interval_count_w;
			done_count_r <= done_count_w;
		end
	end
endmodule