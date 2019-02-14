module choose_mode(
	input clk, rst,
	input [9:0] i_R, 
	input [9:0] i_G,
	input [9:0] i_B,
	input [12:0] i_X_pos, // vga output position
	input [12:0] i_Y_pos, // vga output position
	output detect,
	output clear,
	output [2:0] draw_shape,
	output reg [15:0] color
);
					
parameter X_MAX = 13'd799;
parameter Y_MAX = 13'd599;
parameter X_MAX_fin = 13'd800;
parameter Y_MAX_fin = 13'd600;
parameter FRAME_MAX = 5'd20;

wire [12:0] o_X_pos, o_Y_pos;

// wire check_color = ((i_R[9:5] > 16) && (i_G[9:5] < 6) && (i_B[9:5] < 6));
wire new_frame = ((i_X_pos == 13'd0) && (i_Y_pos == 13'd0));
wire end_frame = ((i_X_pos == X_MAX) && (i_Y_pos == Y_MAX));

/*cursor cursor_mode( .clk(clk), .rst(rst), .i_R(i_R), .i_G(i_G), .i_B(i_B), .i_X_pos(i_X_pos), 
                    .i_Y_pos(i_Y_pos), .check_color(check_color), .detect(detect) );*/

detect_2 detect_mode( .clk(clk), .rst(rst), .i_R(i_R), .i_G(i_G), .i_B(i_B), .i_X_pos(i_X_pos), .i_Y_pos(i_Y_pos), 
                    .new_frame(new_frame), .end_frame(end_frame), .detect(detect), .o_X_pos(o_X_pos), .o_Y_pos(o_Y_pos) );
					

// for draw_shape
parameter draw_dir  = 1;
parameter draw_line = 2;
parameter draw_rec  = 3;
parameter draw_tri  = 4;

// for color
parameter red = 16'b1_11111_00000_00000;        //red
parameter orange = 16'b1_11111_10011_00011;
parameter yellow = 16'b1_11111_11111_00000;     // yellow
parameter green = 16'b1_00000_11111_00000;	    // green
parameter light_blue = 16'b1_00000_11111_11111;	// light blue
parameter blue = 16'b1_00000_00000_11111;	    // blue
parameter purple = 16'b1_11111_00000_11111;     // purple
parameter white = 16'b1_11111_11111_11111;   	//white
parameter black = 16'b1_00000_00000_00000;   	//black
parameter transparent = 16'b0_00000_00000_00000;

parameter block1_y1 = 13'd171;
parameter block1_y2 = 13'd208;
parameter block2_y1 = 13'd209;
parameter block2_y2 = 13'd246;
parameter block3_y1 = 13'd254;
parameter block3_y2 = 13'd291;
parameter block4_y1 = 13'd292;
parameter block4_y2 = 13'd329;
parameter block5_y1 = 13'd330;
parameter block5_y2 = 13'd367;
parameter block6_y1 = 13'd368;
parameter block6_y2 = 13'd405;
parameter block7_y1 = 13'd406;
parameter block7_y2 = 13'd443;
parameter block8_y1 = 13'd444;
parameter block8_y2 = 13'd481;

reg detect_w, detect_r, check_r;
reg [12:0] X_pos_w, X_pos_r, Y_pos_w, Y_pos_r;
reg [15:0] color_now;
reg [4:0] frame_num_w, frame_num_r; // count to 35 vga frame -> output draw_shape
reg [4:0] count_num_w, count_num_r; 
reg [2:0] draw_shape_w, draw_shape_r, shape_w, shape_r, compare_mode;
reg [3:0] compare_color, draw_color_w, draw_color_r, color_w, color_r; // choose color

assign draw_shape = draw_shape_r;
assign clear = (color_r == 10); 

always@(*) begin
	detect_w = (detect_r) ? !end_frame : detect;
	
	case (color_r)
		0 : color = red;
		1 : color = orange;       
		2 : color = yellow;        
		3 : color = green;      
		4 : color = light_blue;     
		5 : color = blue;   
		6 : color = purple;      
		7 : color = white;      
		8 : color = black;
		9 : color = transparent;
		10 : color = transparent;
		default : color = color_now;
	endcase
end

wire check_left  = (X_pos_r > 720) & (X_pos_r < 760);
wire check_right = (X_pos_r > 759) & (X_pos_r < 799);

always@(*) begin
	compare_mode  = shape_r;
	compare_color = color_r;
	if ((X_pos_r < X_MAX) && (Y_pos_r < Y_MAX) && (Y_pos_r > 0) && (X_pos_r > 0)) begin
		if (check_left &&  (Y_pos_r <= block1_y2) && (Y_pos_r >= block1_y1)) compare_mode = draw_dir;        // direct
		else if (check_right && (Y_pos_r <= block1_y2) && (Y_pos_r >= block1_y1)) compare_mode = draw_line;  // line
		else if (check_left  && (Y_pos_r <= block2_y2) && (Y_pos_r >= block2_y1)) compare_mode = draw_rec;   // rectangle
		else if (check_right && (Y_pos_r <= block2_y2) && (Y_pos_r >= block2_y1)) compare_mode = draw_tri;   // triangle
		else if (check_left  && (Y_pos_r <= block3_y2) && (Y_pos_r >= block3_y1)) compare_color = 0; // red
		else if (check_right && (Y_pos_r <= block3_y2) && (Y_pos_r >= block3_y1)) compare_color = 1; // orange
		else if (check_left  && (Y_pos_r <= block4_y2) && (Y_pos_r >= block4_y1)) compare_color = 2; // yellow
		else if (check_right && (Y_pos_r <= block4_y2) && (Y_pos_r >= block4_y1)) compare_color = 3; // green
		else if (check_left  && (Y_pos_r <= block5_y2) && (Y_pos_r >= block5_y1)) compare_color = 4; // light blue
		else if (check_right && (Y_pos_r <= block5_y2) && (Y_pos_r >= block5_y1)) compare_color = 5; // blue
		else if (check_left  && (Y_pos_r <= block6_y2) && (Y_pos_r >= block6_y1)) compare_color = 6; // purple
		else if (check_right && (Y_pos_r <= block6_y2) && (Y_pos_r >= block6_y1)) compare_color = 7; // white
		else if (check_left  && (Y_pos_r <= block7_y2) && (Y_pos_r >= block7_y1)) compare_color = 8; // black
		else if (check_right && (Y_pos_r <= block7_y2) && (Y_pos_r >= block7_y1)) compare_color = 9; // transparent
		else if ((X_pos_r > 720) & (X_pos_r < X_MAX) && (Y_pos_r <= block8_y2) && (Y_pos_r >= block8_y1)) compare_color = 10; // clear
	end 
end
	
always@(*) begin
	if (end_frame) begin
		X_pos_w = X_MAX_fin;
		Y_pos_w = Y_MAX_fin; 
	end else begin
		X_pos_w = (detect) ? o_X_pos : X_pos_r;
		Y_pos_w = (detect) ? o_Y_pos : Y_pos_r;
	end
end
	
always@(*) begin
	draw_color_w = draw_color_r;
	color_w = color_r;
	shape_w = shape_r;
	draw_shape_w = draw_shape_r;
	if (frame_num_r == 0) begin
		frame_num_w  = (detect_r && !check_r);
		count_num_w  = 0;
		draw_shape_w = (detect_r && !check_r) ? compare_mode : draw_shape_r;
		draw_color_w = (detect_r && !check_r) ? compare_color : draw_color_r;
	end else begin
		if (end_frame) begin
			frame_num_w = ((((frame_num_r - count_num_r) > 5) && (frame_num_r > 6)) || (frame_num_r == FRAME_MAX)) ? 0 : (frame_num_r + 1);
		end else begin
			frame_num_w = frame_num_r;
		end
		
		if (((((frame_num_r - count_num_r) > 5) && (frame_num_r > 6)) || (frame_num_r == FRAME_MAX)) && end_frame) begin
			count_num_w  = 0;
			draw_shape_w = (frame_num_r == FRAME_MAX) ? draw_shape_r : shape_r;
			shape_w      = (frame_num_r == FRAME_MAX) ? draw_shape_r : shape_r;
			draw_color_w = (frame_num_r == FRAME_MAX) ? draw_color_r : color_r;
			color_w      = (frame_num_r == FRAME_MAX) ? draw_color_r : color_r;
		end else begin
			count_num_w = (((compare_mode == draw_shape_r) && (compare_color == draw_color_r)) && detect_r && end_frame) ? (count_num_r + 1) : count_num_r;
		end
	end
end

always@(posedge clk) begin
	if (!rst) begin
		detect_r     <= 1'd0;
		check_r      <= 1'd0;
		X_pos_r      <= 0;
		Y_pos_r      <= 0;
		frame_num_r  <= 0;
		draw_color_r <= 2;
		color_r      <= 2;
		draw_shape_r <= draw_line;
		shape_r      <= draw_line;
		count_num_r  <= 0;
		color_now    <= yellow;
	end else begin
		detect_r     <= detect_w;
		check_r      <= detect_r;
		X_pos_r      <= X_pos_w;
		Y_pos_r      <= Y_pos_w;
		frame_num_r  <= frame_num_w;
		draw_color_r <= draw_color_w;
		color_r      <= color_w;
		draw_shape_r <= draw_shape_w;
		shape_r      <= shape_w;
		count_num_r  <= count_num_w;
		color_now    <= color;
	end
end
endmodule