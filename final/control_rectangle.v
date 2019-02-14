module control_rectangle(
	input clk_read,		// VGA clock for detect, draw_line and others
	input clk_write,    // VGA_BAR clock for control
	input rst,
	input [9:0] i_sCCD_R,
	input [9:0] i_sCCD_G,
	input [9:0] i_sCCD_B,
	input [15:0] i_X_Cont,
	input [15:0] i_Y_Cont,
	input [2:0] mode,
	
	output match_rec    // tell the output the input positions i_X_Cont & i_Y_Cont are matched with the rectangle output points x_pos_rec & y_pos_rec
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
	
	//rectangle module
	//wire [15:0] x_to_rec, y_to_rec;		// x、y coordinate to rectangle inputs i_x_pos & i_y_pos
	//wire rec_start;    replace with rec_start_r
	//wire rec_enable;   replace with rec_enable_r
	wire start_to_output_location;         
	wire renew_rec;
	wire all_done_rec;
	wire [15:0] x_pos_rec, y_pos_rec;
	
	// point processing declaration
	reg [15:0] x_to_rec_w, x_to_rec_r;
	reg [15:0] y_to_rec_w, y_to_rec_r;
	
	reg [1:0] point_count_w, point_count_r;
	reg rec_start_w, rec_start_r;
	reg rec_enable_w, rec_enable_r;
	
	// to give the renew signal
	reg renew_rec_flag_w, renew_rec_flag_r;
	
	// new and end frame processing
	reg end_frame_w, end_frame_r;
	reg flag_end_frame_w, flag_end_frame_r;
	wire new_frame_rec;
	
	// interval count
	reg [9:0] interval_count_w, interval_count_r;
	reg [9:0] done_count_w, done_count_r;
	
	
	/*reg [15:0] x_pos_rec_w, x_pos_rec_r;
	reg [15:0] y_pos_rec_w, y_pos_rec_r;*/

	detect detect1(
		.clk(clk_read),
		.rst(rst),
		.i_R(i_sCCD_R),
		.i_G(i_sCCD_G),
		.i_B(i_sCCD_B),
		.i_X_pos(i_X_Cont),
		.i_Y_pos(i_Y_Cont),
		.new_frame(new_frame_rec),
		.end_frame(end_frame_r),
		.detect(detect),
		.o_X_pos(x_pos_detect),
		.o_Y_pos(y_pos_detect)
	);

	rectangle rectangle1(
		.clk(clk_read),
		.rst(rst),
		.i_x_pos(x_to_rec_r),
		.i_y_pos(y_to_rec_r),
		.rec_start(rec_start_r),
		.enable(rec_enable_r),
		.strat_to_output(start_to_output_location),
		.renew_start(renew_rec),
		.new_frame(new_frame_rec),
		.all_done(all_done_rec),
		.o_x_pos(x_pos_rec),
		.o_y_pos(y_pos_rec)
	);
	
	//*******************************************************************************************//
	//*******************************************************************************************//
	// After making sure the last point of a frame, new_frame_rec is better to change to end_frame_rec
	assign new_frame_rec = (mode == RECTANGLE && i_X_Cont ==0 && i_Y_Cont==0) ? 1 : 0;
	
	assign start_to_output_location = ((mode == RECTANGLE) && (end_frame_r==1) && (renew_rec_flag_r==1)) ? 1 : 0;
	assign renew_rec = ((mode == RECTANGLE) && (x_pos_rec == i_X_Cont) && (y_pos_rec == i_Y_Cont) && (all_done_rec != 1)) ? 1 : 0;
	assign match_rec = ((mode == RECTANGLE) && (x_pos_rec == i_X_Cont) && (y_pos_rec == i_Y_Cont) && (done_count_r == 1)) ? 1 : 0;    // done_count_r is a dummy signal 
	
	always@ (*) begin
		x_to_rec_w = x_to_rec_r;
		y_to_rec_w = y_to_rec_r;
		point_count_w = point_count_r;
		rec_start_w = rec_start_r;
		rec_enable_w = rec_enable_r;
		if(mode == RECTANGLE) begin
			if(detect == 1 && point_count_r == 0) begin
				point_count_w = 1;
				x_to_rec_w = x_pos_detect;
				y_to_rec_w = y_pos_detect;
				rec_start_w = 1;
			end
			else if(detect == 1 && point_count_r == 1 && interval_count_r == INTERVAL) begin
				point_count_w = 2;
				x_to_rec_w = x_pos_detect;
				y_to_rec_w = y_pos_detect;
				rec_enable_w = 1;
			end
			else if(done_count_r == INTERVAL) begin  // able to draw the next graph
				point_count_w = 0;
			end
			else begin
				rec_start_w = 0;
				rec_enable_w = 0;
			end
		end
		else;
	end
	always@ (*) begin
		if (rec_enable_r == 1) renew_rec_flag_w = 1;
		else if (end_frame_r == 1) renew_rec_flag_w = 0;
		else renew_rec_flag_w = renew_rec_flag_r;
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
		if(i_X_Cont == X_LAST_POINT && i_Y_Cont== Y_LAST_POINT && flag_end_frame_r != 1) begin
			end_frame_w = 1;
			flag_end_frame_w = 1;
		end
		else if(new_frame_rec==1) begin
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
			x_to_rec_r <= 801;
			y_to_rec_r <= 601;
			point_count_r <= 0;
			rec_start_r <= 0;
			rec_enable_r <= 0;
			renew_rec_flag_r <= 0;
			
			// end_frame
			end_frame_r <= 0;
			flag_end_frame_r <= 0;
			
			// interval count
			interval_count_r <= 0;
			done_count_r <= 0;
			
		end
		else begin
			x_to_rec_r <= x_to_rec_w;
			y_to_rec_r <= y_to_rec_w;
			point_count_r <= point_count_w;
			rec_start_r <= rec_start_w;
			rec_enable_r <= rec_enable_w;
			renew_rec_flag_r <= renew_rec_flag_w;
			
			// end_frame
			end_frame_r <= end_frame_w;
			flag_end_frame_r <= flag_end_frame_w;
			
			// interval count
			interval_count_r <= interval_count_w;
			done_count_r <= done_count_w;
			
		end
	end

endmodule