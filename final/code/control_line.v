module control_line(
	input clk_read,		// VGA clock for detect, draw_line and others
	input clk_write,    // VGA_BAR clock for control
	input rst,
	input [9:0] i_sCCD_R,
	input [9:0] i_sCCD_G,
	input [9:0] i_sCCD_B,
	input [15:0] i_X_Cont,
	input [15:0] i_Y_Cont,
	input [2:0] mode,
	
	output match_line    // tell the output the input positions i_X_Cont & i_Y_Cont are matched with the draw_line output points x_pos_line & y_pos_line
	
);
	localparam DRAW_LINE = 3'd0;
	localparam RECTANGLE = 3'd1;
	localparam TRIANGLE = 3'd2;
	
	localparam X_LAST_POINT = 799;
	localparam Y_LAST_POINT = 599;
	
	// detect module
	wire detect;
	wire [15:0] x_pos_detect, y_pos_detect;
	
	// draw_line module
	reg line_enable_w, line_enable_r;
	wire renew_line;
	wire new_frame;
	//wire [15:0] x1_to_line, y1_to_line, x2_to_line, y2_to_line;		// x、y coordinate to draw_line inputs i_X_pos_1、i_Y_pos_1、i_X_pos_2、i_Y_pos_2
	wire [15:0] x_pos_line, y_pos_line;
	wire done_line;
	
	
	// counter
	reg [1:0] count_w, count_r;	// to count the number of points which has been detected
	reg [3:0] line_count_w, line_count_r; // count to detect drawing the same or different lines
	reg flag_w, flag_r;
	reg different_line_w, different_line_r;
	reg renew_line_flag_w, renew_line_flag_r;
	reg count_enable_w, count_enable_r;
	
	
	reg [15:0] x_point1_w, x_point1_r;
	reg [15:0] y_point1_w, y_point1_r;
	reg [15:0] x_point2_w, x_point2_r;
	reg [15:0] y_point2_w, y_point2_r;
	reg end_frame_w, end_frame_r;
	reg flag_end_frame_w, flag_end_frame_r;
	
	//**************************************assign value to wire signal*************************************************
	// draw_line
	assign new_frame = (i_X_Cont ==0 && i_Y_Cont==0) ? 1 : 0;
	assign renew_line = (/*((mode == DRAW_LINE) && (new_frame == 1) && (renew_line_flag_r == 1)) ||*/ ((mode == DRAW_LINE) && (x_pos_line == i_X_Cont) && (y_pos_line == i_Y_Cont) && (done_line != 1) && (renew_line_flag_r == 1))) ? 1 : 0;
	assign match_line = ((mode == DRAW_LINE) && (x_pos_line == i_X_Cont) && (y_pos_line == i_Y_Cont) && (new_frame == 0) && (renew_line_flag_r == 1)) ? 1 : 0;
	
	
	detect detect1(
		.clk(clk_read),
		.rst(rst),
		.i_R(i_sCCD_R),
		.i_G(i_sCCD_G),
		.i_B(i_sCCD_B),
		.i_X_pos(i_X_Cont),
		.i_Y_pos(i_Y_Cont),
		.new_frame(new_frame),
		.end_frame(end_frame_r),
		.detect(detect),
		.o_X_pos(x_pos_detect),
		.o_Y_pos(y_pos_detect)
	);
	
	draw_line draw_line1(
		.clk(clk_read),
		.rst(rst),
		.draw_line_enable(line_enable_r),
		.renew_output(renew_line),
		.end_frame(end_frame_r),
		.i_X_pos_1(x_point1_r),
		.i_Y_pos_1(y_point1_r),
		.i_X_pos_2(x_point2_r),
		.i_Y_pos_2(y_point2_r),
		.o_X_pos(x_pos_line),
		.o_Y_pos(y_pos_line),
		.done(done_line),
		.different_line(different_line_w)
	);
	
	
	// detect drawing the same or different lines
	always@ (*) begin
		flag_w = flag_r;
		line_count_w = line_count_r;
		different_line_w = different_line_r;
		if(new_frame != 1) begin
			if(detect==0 && flag_r==0 && line_count_r != 8) begin
				line_count_w = line_count_r + 1;
				flag_w = 1;
			end
			else if (detect==1) begin
				line_count_w = 0;
				flag_w = 1;
			end
			else begin  // detect == 0 && flag_r == 1
				line_count_w = line_count_r;
				flag_w = flag_r;
			end
		end
		else begin
			line_count_w = line_count_r;
			flag_w = 0;
		end
		
		if(new_frame == 1 && line_count_r == 8) begin
			different_line_w = 1;
		end
		else if (detect == 1) begin
			different_line_w = 0;
		end
		else;
	end
	// draw_line module only
	always@ (*) begin
		x_point1_w = x_point1_r;
		y_point1_w = y_point1_r;
		x_point2_w = x_point2_r;
		y_point2_w = y_point2_r;
		count_w = count_r;
		line_enable_w = line_enable_r;
		if(mode == DRAW_LINE) begin
			if(detect == 1 && count_r == 0) begin
				count_w = 1;
				x_point1_w = x_pos_detect;
				y_point1_w = y_pos_detect;
				line_enable_w = 0;
			end
			else if(detect == 1 && count_r == 1) begin
				count_w = 2;
				x_point2_w = x_pos_detect;
				y_point2_w = y_pos_detect;
				line_enable_w = 1;
			end
			else if(detect == 1 && count_r == 2) begin
				if(different_line_r == 0) begin// draw the same line now
					count_w = 2;
					x_point1_w = x_point2_r;
					y_point1_w = y_point2_r;
					x_point2_w = x_pos_detect;
					y_point2_w = y_pos_detect;
					line_enable_w = 1;
				end
				else ;
				/*else begin     // draw the different line
					count_w = 0;
				end*/
			end
			else if(different_line_r == 1 && end_frame_r == 1) begin
				count_w = 0;
			end
			else if (detect == 0) begin
				line_enable_w = 0;
			end
			else;
		end
		else ;
	end
	// renew
	always@ (*) begin
		if (line_enable_r == 1) begin 
			count_enable_w = 1;
		end
		else if (end_frame_r == 1 && count_enable_r == 1) begin
			renew_line_flag_w = 1;
			count_enable_w = 0;
		end
		else if (end_frame_r == 1 && count_enable_r == 0) begin
			renew_line_flag_w = 0;
			count_enable_w = 0;
		end
		else begin
			renew_line_flag_w = renew_line_flag_r;
			count_enable_w = count_enable_r;
		end
	end
	always@ (*) begin
		end_frame_w = end_frame_r;
		flag_end_frame_w = flag_end_frame_r;
		if(i_X_Cont ==X_LAST_POINT && i_Y_Cont==Y_LAST_POINT && flag_end_frame_r != 1) begin
			end_frame_w = 1;
			flag_end_frame_w = 1;
		end
		else if(new_frame==1) begin
			end_frame_w = 0;
			flag_end_frame_w = 0;
		end
		else begin
			end_frame_w = 0;
			flag_end_frame_w = flag_end_frame_r;
		end
	end
	always@ (posedge clk_write) begin
		if(!rst) begin
			count_r <= 0;
			line_enable_r <= 0;
			x_point1_r <= 0;
			y_point1_r <= 0;
			x_point2_r <= 0;
			y_point2_r <= 0;
			
			// different line
			line_count_r <= 0;
			flag_r <= 0;
			different_line_r <= 0;
			
			// renew
			renew_line_flag_r <= 0;
			
			// end_frame
			end_frame_r <= 0;
			flag_end_frame_r <= 0;
			
			count_enable_r <= 0;
		end
		else begin
			count_r <= count_w;
			line_enable_r <= line_enable_w;
			x_point1_r <= x_point1_w;
			y_point1_r <= y_point1_w;
			x_point2_r <= x_point2_w;
			y_point2_r <= y_point2_w;
			
			// different line
			line_count_r <= line_count_w;
			flag_r <= flag_w;
			different_line_r <= different_line_w;
			
			// renew
			renew_line_flag_r <= renew_line_flag_w;
			
			// end_frame
			end_frame_r <= end_frame_w;
			flag_end_frame_r <= flag_end_frame_w;
			
			count_enable_r <= count_enable_w;
		end
	end
endmodule