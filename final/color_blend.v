module color_blend(
	// color saved in sdram
	input [4:0] i_draw_R_sdram,
	input [4:0] i_draw_G_sdram,
	input [4:0] i_draw_B_sdram,
	// color wanted to draw
	input [4:0] i_draw_R,
	input [4:0] i_draw_G,
	input [4:0] i_draw_B,
	// color needed to be saved in sdram
	output [4:0] o_draw_R,
	output [4:0] o_draw_G,
	output [4:0] o_draw_B
);

parameter MAX_PIXEL_COLOR = 31;
parameter MAX_PIXEL_LENGTH = 5;

wire [4:0] inv_color_R_sdram = MAX_PIXEL_COLOR - i_draw_R_sdram;
wire [4:0] inv_color_G_sdram = MAX_PIXEL_COLOR - i_draw_G_sdram;
wire [4:0] inv_color_B_sdram = MAX_PIXEL_COLOR - i_draw_B_sdram;

wire [4:0] inv_color_R = MAX_PIXEL_COLOR - i_draw_R;
wire [4:0] inv_color_G = MAX_PIXEL_COLOR - i_draw_G;
wire [4:0] inv_color_B = MAX_PIXEL_COLOR - i_draw_B;

wire [5:0] add_R = inv_color_R_sdram + inv_color_R;
wire [5:0] add_G = inv_color_G_sdram + inv_color_G;
wire [5:0] add_B = inv_color_B_sdram + inv_color_B;

wire max_R = (({6{(add_R > add_G) && (add_R > add_B)}} & add_R) > MAX_PIXEL_COLOR) ? 1 : 0;
wire max_G = (({6{(add_G > add_B) && (add_G > add_R)}} & add_G) > MAX_PIXEL_COLOR) ? 1 : 0;
wire max_B = (({6{(add_B > add_R) && (add_B > add_G)}} & add_B) > MAX_PIXEL_COLOR) ? 1 : 0;

wire max_RG = (({6{(add_R == add_G) && (add_R > add_B)}} & add_R) > MAX_PIXEL_COLOR) ? 1 : 0;
wire max_GB = (({6{(add_G == add_B) && (add_G > add_R)}} & add_G) > MAX_PIXEL_COLOR) ? 1 : 0;
wire max_BR = (({6{(add_B == add_R) && (add_B > add_G)}} & add_B) > MAX_PIXEL_COLOR) ? 1 : 0;

wire max_RGB = (({6{(add_B == add_R) && (add_B == add_G)}} & add_B) > MAX_PIXEL_COLOR) ? 1 : 0;

reg [11:0] R, G, B;

always @ (*) begin
	if (max_R || max_RG || max_RGB) begin
		R = MAX_PIXEL_COLOR;
		G = ((add_G << MAX_PIXEL_LENGTH) - add_G) / add_R;
		B = ((add_B << MAX_PIXEL_LENGTH) - add_B) / add_R;
	end else if (max_G || max_GB) begin
		R = ((add_R << MAX_PIXEL_LENGTH) - add_R) / add_G;
		G = MAX_PIXEL_COLOR;
		B = ((add_B << MAX_PIXEL_LENGTH) - add_B) / add_G;
	end else if (max_B || max_BR) begin	
		R = ((add_R << MAX_PIXEL_LENGTH) - add_R) / add_B;
		G = ((add_G << MAX_PIXEL_LENGTH) - add_G) / add_B;
		B = MAX_PIXEL_COLOR;
	end else begin
		R = {4'd0, add_R};
		G = {4'd0, add_G};
		B = {4'd0, add_B};
	end
		
end

assign o_draw_R = MAX_PIXEL_COLOR[4:0] - R[4:0];
assign o_draw_G = MAX_PIXEL_COLOR[4:0] - G[4:0];
assign o_draw_B = MAX_PIXEL_COLOR[4:0] - B[4:0];

endmodule