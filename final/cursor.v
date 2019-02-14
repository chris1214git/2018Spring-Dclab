module cursor(
	input clk, rst,
	input [12:0] i_X_pos, // vga output position
	input [12:0] i_Y_pos, // vga output position
	input check_color,
	// input [2:0] cursor_size, 
	output reg detect
);

parameter cursor_size = 13'd4;
parameter X_MAX = 13'd799;
parameter Y_MAX = 13'd599;
parameter X_MAX_fin = 13'd800;
parameter Y_MAX_fin = 13'd600;
parameter X_comp_MAX = 13'd794; // X_MAX - cursor_size - 12'd1;
parameter Y_comp_MAX = 13'd595; // Y_MAX - cursor_size;

reg  detect_color_w, detect_color_r, check_color_r;
reg  [12:0] X_pos1_w, Y_pos1_w, X_pos1_r, Y_pos1_r;
reg  [12:0] X_pos2_w, Y_pos2_w, X_pos2_r, Y_pos2_r;

wire detect_w = (((i_X_pos > X_pos1_r) && (i_Y_pos > Y_pos1_r)) && ((i_X_pos <= X_pos2_r) && (i_Y_pos <= Y_pos2_r)) && detect_color_r);

// wire check_color = ((i_R[9:5] > 16) && (i_G[9:5] < 6) && (i_B[9:5] < 6));

always@(*) begin
	if (detect_color_r) begin
		detect_color_w = ~((i_Y_pos == Y_MAX) && (i_X_pos == X_MAX));
		X_pos1_w = X_pos1_r;
		Y_pos1_w = Y_pos1_r;
		X_pos2_w = X_pos2_r;
		Y_pos2_w = Y_pos2_r;
	end else begin
		detect_color_w = check_color_r;
		X_pos1_w = (check_color_r && (i_X_pos < X_comp_MAX)) ? i_X_pos : X_pos1_r;
		Y_pos1_w = (check_color_r && (i_Y_pos < Y_comp_MAX)) ? i_Y_pos : Y_pos1_r;
		X_pos2_w = (check_color_r && (i_X_pos < X_comp_MAX)) ? (i_X_pos + cursor_size) : X_pos2_r;
		Y_pos2_w = (check_color_r && (i_Y_pos < Y_comp_MAX)) ? (i_Y_pos + cursor_size) : Y_pos2_r;
	end
end

always@(posedge clk) begin
	if (!rst) begin
		detect_color_r <= 1'd0;
		check_color_r  <= 1'd0;
		detect         <= 1'd0;
		X_pos1_r       <= X_MAX_fin;
		Y_pos1_r       <= Y_MAX_fin;
		X_pos2_r       <= X_MAX_fin;
		Y_pos2_r       <= Y_MAX_fin;
	end else begin
		detect_color_r <= detect_color_w;
		check_color_r  <= check_color;
		detect         <= detect_w;
		X_pos1_r       <= X_pos1_w;
		Y_pos1_r       <= Y_pos1_w;
		X_pos2_r       <= X_pos2_w;
		Y_pos2_r       <= Y_pos2_w;
	end
end
	
endmodule