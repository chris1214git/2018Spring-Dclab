// detect where the first red point appears
module detect_state(
	input clk, rst,
	input [9:0] i_R, 
	input [9:0] i_G,
	input [9:0] i_B,
	input [15:0] i_X_pos, // ccd output position
	input [15:0] i_Y_pos, // ccd output position
	input new_frame,
	input end_frame,
	output reg detect,
	output reg [15:0] o_X_pos,
	output reg [15:0] o_Y_pos
);

reg  detect_color_w, detect_color_r;
reg  [15:0] X_pos_w, Y_pos_w;
wire detect_w;
reg  flag_w, flag_r;

assign detect_w = (!detect_color_r && detect_color_w) ? 1 : 0;

always@(*) begin
	if (detect_color_r) begin
		detect_color_w = (i_Y_pos == 0) ? 0 : 1;
		X_pos_w = o_X_pos;
		Y_pos_w = o_Y_pos;
	end else begin
		detect_color_w = (flag_w && ((i_R[9:5] > 16 && i_G[9:5] < 6) && (i_B[9:5] < 6))) ? 1 : 0;
		X_pos_w = (flag_w && ((i_R[9:5] > 16 && i_G[9:5] < 6) && (i_B[9:5] < 6))) ? i_X_pos : o_X_pos;
		Y_pos_w = (flag_w && ((i_R[9:5] > 16 && i_G[9:5] < 6) && (i_B[9:5] < 6))) ? i_Y_pos : o_Y_pos;
	end
	if (end_frame || new_frame) begin
		flag_w = (new_frame) ? 1 : 0;
	end else begin
		flag_w = flag_r;
	end
end

always@(posedge clk) begin
	if (!rst) begin
		detect_color_r <= 0;
		o_X_pos <= 0;
		o_Y_pos <= 0;
		detect  <= 0;
		flag_r  <= 0;
	end else begin
		detect_color_r <= detect_color_w;
		o_X_pos <= X_pos_w;
		o_Y_pos <= Y_pos_w;
		detect  <= detect_w;
		flag_r  <= flag_w;
	end
end
endmodule