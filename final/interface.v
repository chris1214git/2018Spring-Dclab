module interface(
	input clk,
	input rst_n,
	input [12:0] x_pos,
	input [12:0] y_pos,
	
	input [15:0]  current_color,		//color1~8, erase
	input [2:0]  draw_shape,		//dir, line, rec

	output reg match,
	output reg [15:0] color
);
parameter black = 16'b1_00000_00000_00000;	//black
parameter blue = 16'b1_00000_00000_11111;	//blue
parameter green = 16'b1_00000_11111_00000;	//green
parameter red = 16'b1_11111_00000_00000; //red
parameter light_blue = 16'b1_00000_11111_11111;	//light blue
parameter purple = 16'b1_11111_00000_11111; //purple
parameter yellow = 16'b1_11111_11111_00000; //yellow
parameter white = 16'b1_11111_11111_11111;	//white
parameter orange = 16'b1_11111_10011_00011;
parameter transparent = 16'b0_00000_00000_00000;

parameter gray = 16'b1_10011_10011_10011;   //gray
parameter brown = {1'd1, 5'd17, 5'd8, 5'd2};

parameter draw_dir  = 1;
parameter draw_line = 2;
parameter draw_rec  = 3;
parameter draw_tri  = 4;

parameter line_width  = 2;
parameter current_block_height = 80;

parameter x_left = 720;
parameter x_middle = 760;
parameter x_right = 799;

// block_cur_mode
parameter block1 = 1;
parameter block2 = 2;
parameter block3 = 3;
parameter block4 = 4;

// block_color
parameter block_red =  1;
parameter block_org =  2;
parameter block_yel =  3;
parameter block_gre =  4;
parameter block_lblu=  5;
parameter block_blu =  6;
parameter block_pur =  7;
parameter block_whi =  8;
parameter block_bla =  9;
parameter block_era = 10;
parameter block_clear = 11;

// block_mode
parameter block_dir = 1;
parameter block_line = 2;
parameter block_rec = 3;
parameter block_tri = 4;


wire [0:64] tri_point [32:0];

assign tri_point[0] =65'b00000_00000_00000_00000_00000_00000_01000_00000_00000_00000_00000_00000_00000;
assign tri_point[1] =65'b00000_00000_00000_00000_00000_00000_11000_00000_00000_00000_00000_00000_00000;
assign tri_point[2] =65'b00000_00000_00000_00000_00000_00001_10110_00000_00000_00000_00000_00000_00000;
assign tri_point[3] =65'b00000_00000_00000_00000_00000_00011_00011_00000_00000_00000_00000_00000_00000;
assign tri_point[4] =65'b00000_00000_00000_00000_00000_00110_00001_10000_00000_00000_00000_00000_00000;
assign tri_point[5] =65'b00000_00000_00000_00000_00000_01100_00000_11000_00000_00000_00000_00000_00000;
assign tri_point[6] =65'b00000_00000_00000_00000_00000_11000_00000_01100_00000_00000_00000_00000_00000;
assign tri_point[7] =65'b00000_00000_00000_00000_00001_10000_00000_00110_00000_00000_00000_00000_00000;
assign tri_point[8] =65'b00000_00000_00000_00000_00011_00000_00000_00011_00000_00000_00000_00000_00000;
assign tri_point[9] =65'b00000_00000_00000_00000_00110_00000_00000_00001_10000_00000_00000_00000_00000;
assign tri_point[10]=65'b00000_00000_00000_00000_01100_00000_00000_00000_11000_00000_00000_00000_00000;
assign tri_point[11]=65'b00000_00000_00000_00000_11000_00000_00000_00000_01100_00000_00000_00000_00000;
assign tri_point[12]=65'b00000_00000_00000_00001_10000_00000_00000_00000_00110_00000_00000_00000_00000;
assign tri_point[13]=65'b00000_00000_00000_00011_00000_00000_00000_00000_00011_00000_00000_00000_00000;
assign tri_point[14]=65'b00000_00000_00000_00110_00000_00000_00000_00000_00001_10000_00000_00000_00000;
assign tri_point[15]=65'b00000_00000_00000_01100_00000_00000_00000_00000_00000_11000_00000_00000_00000;
assign tri_point[16]=65'b00000_00000_00000_11000_00000_00000_00000_00000_00000_01100_00000_00000_00000;
assign tri_point[17]=65'b00000_00000_00001_10000_00000_00000_00000_00000_00000_00110_00000_00000_00000;
assign tri_point[18]=65'b00000_00000_00011_00000_00000_00000_00000_00000_00000_00011_00000_00000_00000;
assign tri_point[19]=65'b00000_00000_00110_00000_00000_00000_00000_00000_00000_00001_10000_00000_00000;
assign tri_point[20]=65'b00000_00000_01100_00000_00000_00000_00000_00000_00000_00000_11000_00000_00000;
assign tri_point[21]=65'b00000_00000_11000_00000_00000_00000_00000_00000_00000_00000_01100_00000_00000;
assign tri_point[22]=65'b00000_00001_10000_00000_00000_00000_00000_00000_00000_00000_00110_00000_00000;
assign tri_point[23]=65'b00000_00011_00000_00000_00000_00000_00000_00000_00000_00000_00011_00000_00000;
assign tri_point[24]=65'b00000_00110_00000_00000_00000_00000_00000_00000_00000_00000_00001_10000_00000;
assign tri_point[25]=65'b00000_01100_00000_00000_00000_00000_00000_00000_00000_00000_00000_11000_00000;
assign tri_point[26]=65'b00000_11000_00000_00000_00000_00000_00000_00000_00000_00000_00000_01100_00000;
assign tri_point[27]=65'b00001_10000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00110_00000;
assign tri_point[28]=65'b00011_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00011_00000;
assign tri_point[29]=65'b00110_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00001_10000;
assign tri_point[30]=65'b01100_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000_11000;
assign tri_point[31]=65'b01111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11110;
assign tri_point[32]=65'b11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111;


wire [0:30] tri_mode [15:0];

assign tri_mode[0] =31'b00000_00000_00001_00000_00000_00000_0;
assign tri_mode[1] =31'b00000_00000_00011_00000_00000_00000_0;
assign tri_mode[2] =31'b00000_00000_00110_11000_00000_00000_0;
assign tri_mode[3] =31'b00000_00000_01100_01100_00000_00000_0;
assign tri_mode[4] =31'b00000_00000_11000_00110_00000_00000_0;
assign tri_mode[5] =31'b00000_00001_10000_00011_00000_00000_0;
assign tri_mode[6] =31'b00000_00011_00000_00001_10000_00000_0;
assign tri_mode[7] =31'b00000_00110_00000_00000_11000_00000_0;
assign tri_mode[8] =31'b00000_01100_00000_00000_01100_00000_0;
assign tri_mode[9] =31'b00000_11000_00000_00000_00110_00000_0;
assign tri_mode[10]=31'b00001_10000_00000_00000_00011_00000_0;
assign tri_mode[11]=31'b00011_00000_00000_00000_00001_10000_0;
assign tri_mode[12]=31'b00110_00000_00000_00000_00000_11000_0;
assign tri_mode[13]=31'b01100_00000_00000_00000_00000_01100_0;
assign tri_mode[14]=31'b01111_11111_11111_11111_11111_11111_0;
assign tri_mode[15]=31'b11111_11111_11111_11111_11111_11111_1;

wire [69:0] clr [30:0];

assign clr[0]  = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[1]  = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[2]  = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[3]  = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[4]  = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[5]  = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[6]  = 70'b0000000000000000111000000000001110000000000000111111000000000000000000;
assign clr[7]  = 70'b0000000000000011111100000000001110000000000000111111110000000000000000;
assign clr[8]  = 70'b0000000000000111001110000000001110000000000000110000111000000000000000;
assign clr[9]  = 70'b0000000000001110000111000000001110000000000000110000011000000000000000;
assign clr[10] = 70'b0000000000011110000000000000001110000000000000110000001100000000000000;
assign clr[11] = 70'b0000000000011100000000000000001110000000000000110000001100000000000000;
assign clr[12] = 70'b0000000000011100000000000000001110000000000000110000011000000000000000;
assign clr[13] = 70'b0000000000011100000000000000001110000000000000110000110000000000000000;
assign clr[14] = 70'b0000000000011100000000000000001110000000000000111111100000000000000000;
assign clr[15] = 70'b0000000000011100000000000000001110000000000000111111000000000000000000;
assign clr[16] = 70'b0000000000011100000000000000001110000000000000110011000000000000000000;
assign clr[17] = 70'b0000000000011100000000000000001110000000000000110011000000000000000000;
assign clr[18] = 70'b0000000000001110000000000000001110000000000000110001100000000000000000;
assign clr[19] = 70'b0000000000001110000111000000001110000000000000110001110000000000000000;
assign clr[20] = 70'b0000000000000111001110000000001110000110000000110000110000000000000000;
assign clr[21] = 70'b0000000000000011111100000000001111111110000000110000111000000000000000;
assign clr[22] = 70'b0000000000000000111000000000001111111110000000110000011100000000000000;
assign clr[23] = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[24] = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[25] = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[26] = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[27] = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[28] = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[29] = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
assign clr[30] = 70'b0000000000000000000000000000000000000000000000000000000000000000000000;

reg [2:0]  draw_shape_r;
wire [2:0] block_cur_mode;
assign block_cur_mode = (y_pos>= 0 && y_pos <= 79) ? block1 : (y_pos>= 85 && y_pos <= 164) ? block2 : (y_pos>= 170 && y_pos <= 247) ? block3 : (y_pos>= 253 && y_pos <= 482) ? block4 : 0;

wire [3:0] block_color;
assign block_color = (y_pos>= 258 && y_pos <= 287 && x_pos>= 725 && x_pos <= 755) ? block_red : (y_pos>= 258 && y_pos <= 287 && x_pos>= 764 && x_pos <= 794) ? block_org : (y_pos>= 296 && y_pos <= 325 && x_pos>= 725 && x_pos <= 755) ? block_yel : (y_pos>= 296 && y_pos <= 325 && x_pos>= 764 && x_pos <= 794) ? block_gre : (y_pos>= 334 && y_pos <= 363 && x_pos>= 725 && x_pos <= 755) ? block_lblu : (y_pos>= 334 && y_pos <= 363 && x_pos>= 764 && x_pos <= 794) ? block_blu : (y_pos>= 372 && y_pos <= 401 && x_pos>= 725 && x_pos <= 755) ? block_pur : (y_pos>= 372 && y_pos <= 401 && x_pos>= 764 && x_pos <= 794) ? block_whi : (y_pos>= 410 && y_pos <= 439 && x_pos>= 725 && x_pos <= 755) ? block_bla : (y_pos>= 410 && y_pos <= 439 && x_pos>= 764 && x_pos <= 794) ? block_era : (y_pos>= 447 && y_pos <= 477 && x_pos>= 725 && x_pos <= 794) ? block_clear : 0;                                                                       

wire [2:0] block_mode;
assign block_mode = (y_pos>= 188 && y_pos <= 191 && x_pos>= 725 && x_pos <= 755) ? block_dir : ((y_pos==189 || y_pos==190) && x_pos>= 764 && x_pos <= 794) ? block_line : (y_pos>= 213 && y_pos <= 242 && x_pos>= 725 && x_pos <= 755) ? block_rec : (y_pos>= 220 && y_pos <= 235 && x_pos>= 764 && x_pos <= 794) ? block_tri : 0;

// the first block (current color)
always@(*) begin
	match = 0;
	color = black;
	case(block_cur_mode)
		// the first block (current color)
		block1 : begin
			if(y_pos==0 || y_pos==1 || y_pos==78 || y_pos==79) begin
				if(x_pos>=720 && x_pos<=799) match = 1;
				else match = 0;
			end
			else if(y_pos >= 2 && y_pos <= 77) begin
				if(x_pos==720 || x_pos==721 || x_pos==798 || x_pos==799) match = 1;
				// the current color location
				else if(y_pos >= 7 && y_pos <= 72 && x_pos >= 727 && x_pos <= 792 && current_color != transparent) begin
					match = 1;
					color = current_color;
				end
				else ;
			end
			else;
		end
	
		// the second block (current mode)
		block2 : begin
			if(y_pos==85 || y_pos==86 || y_pos==163 || y_pos==164) begin
				if(x_pos>=720 && x_pos<=799) match = 1;
				else match = 0;
			end
			else if(y_pos >= 87 && y_pos <= 162) begin
				if(x_pos==720 || x_pos==721 || x_pos==798 || x_pos==799) match = 1;
				else begin
					case (draw_shape)
						draw_line : begin
							if((y_pos == 125) || (y_pos == 126)) begin
								if(x_pos >= 727 && x_pos <= 792) begin
									match = 1;
									color = current_color;
								end
								else;
							end
							else;
						end
						
						draw_rec : begin
							if((y_pos == 92) || (y_pos == 93) || (y_pos == 157) || (y_pos == 158)) begin
								if((x_pos >= 727) && (x_pos <= 792)) begin
									match = 1;
									color = current_color;
								end
								else ;
							end
							else if((y_pos >= 94) && (y_pos <= 156)) begin
								if((x_pos==727) || (x_pos==728) || (x_pos==791) || (x_pos==792)) begin
									match = 1;
									color = current_color;
								end
								else;
							end
							else;
						end
					
						draw_dir : begin
							if((y_pos == 124) || (y_pos == 126)) begin
								if((x_pos >= 727) && (x_pos <= 791) && (x_pos[0] == 1)) begin
									match = 1;
									color = current_color;
								end
								else;
							end
							else if((y_pos == 125) || (y_pos == 127)) begin
								if((x_pos >= 728) && (x_pos <= 790) && (x_pos[0] == 0)) begin
									match = 1;
									color = current_color;
								end
								else;
							end
							else;
						end
						
						draw_tri : begin
							if((y_pos >= 109) && (y_pos <= 141) && (x_pos >= 727) && (x_pos <= 791)) begin
								if(tri_point[y_pos-109][x_pos-727] == 1) begin
									match = 1;
									color = current_color;
								end
								else;
							end
							else;
						end
						default : begin	
							match = 0;
							color = black;
						end
					endcase
				end
			end
		end
	
		// the third block (choosing mode)
		block3 : begin
			if(y_pos==170 || y_pos==171 || y_pos==208 || y_pos==209 || y_pos==246 || y_pos==247) begin
				if(x_pos>=720 && x_pos<=799) match = 1;
				else match = 0;
			end
			else if(y_pos >= 172 && y_pos <= 245) begin
				if(x_pos==720 || x_pos==721 || x_pos==759 || x_pos==760 || x_pos==798 || x_pos==799) match = 1;
				else begin
					case(block_mode)
						block_dir: begin
							if(y_pos==188 || y_pos==190) begin
								if(x_pos >= 725 && x_pos <= 755 && x_pos[0]==1) begin
									match = 1;
									color = gray;
								end
								else begin
									match = 0;
									color = black;
								end
							end
							else if(y_pos==189 || y_pos==191) begin
								if(x_pos >= 726 && x_pos <= 754 && x_pos[0]==0) begin
									match = 1;
									color = gray;
								end
								else begin
									match = 0;
									color = black;
								end
							end
							else begin
								match = 0;
								color = black;
							end
						end
						block_line: begin
							match = 1;
							color = gray;
						end
						block_rec: begin
							if(y_pos==213 || y_pos==214 || y_pos==241 || y_pos==242) begin
								if(x_pos>=725 && x_pos<=755) begin
									match = 1;
									color = gray;
								end
								else match = 0;
							end
							else if(y_pos >= 215 && y_pos <= 240) begin
								if(x_pos==725 || x_pos==726 || x_pos==754 || x_pos==755) begin
									match = 1;
									color = gray;
								end
								else match = 0;
							end
							else match = 0;
						end
						block_tri: begin
							if(tri_mode[y_pos-220][x_pos-764] == 1) begin
								match = 1;
								color = gray;
							end
							else match = 0;
						end
						default : begin
							match = 0;
							color = black;
						
						end
					endcase
				end
			end
			else;
		end
	
	
		// the fourth block (choosing color)
		block4 : begin
			if(y_pos==253 || y_pos==254 || y_pos==291 || y_pos==292 || y_pos==329 || y_pos==330 || y_pos==367 || y_pos==368 || y_pos==405 || y_pos==406 || y_pos==443 || y_pos==444 || y_pos==481 || y_pos==482) begin
				if(x_pos>=720 && x_pos<=799) match = 1;
				else match = 0;
			end
			else if(y_pos >= 255 && y_pos <= 480) begin
				if(y_pos<=442 && (x_pos==720 || x_pos==721 || x_pos==759 || x_pos==760 || x_pos==798 || x_pos==799)) match = 1;
				else if(y_pos>=445 && (x_pos==720 || x_pos==721 || x_pos==798 || x_pos==799)) match = 1;
				else begin
					case(block_color) 
						block_red : begin
							match = 1;
							color = red;
						end
						block_org : begin
							match = 1;
							color = orange;
						end
						block_yel : begin
							match = 1;
							color = yellow;
						end
						block_gre : begin
							match = 1;
							color = green;
						end
						block_lblu : begin
							match = 1;
							color = light_blue;
						end
						block_blu : begin
							match = 1;
							color = blue;
						end
						block_pur : begin
							match = 1;
							color = purple;
						end
						block_whi : begin
							match = 1;
							color = white;
						end
						block_bla : begin
							match = 1;
							color = black;
						end
						block_era : begin
							match = 0;			// note that match = 0 when color = transparent
							color = transparent;
						end
						block_clear : begin
							if(clr[y_pos-447][x_pos-725] == 1) begin
								match = 1;
								color = brown;
							end
							else begin
								match = 0; 
								color = black;
							end
						end
						default : begin
							match = 0; 
							color = black;
						end
					endcase
				end
			end
			else ;
		end
	endcase
end

endmodule
