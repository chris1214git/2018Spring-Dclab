module fft_calfre(
input  clk, //750k
input  rst_n,
input  		   source_startofpacket,
input  [17:0]  source_real,
input  [17:0]  source_imag,
input  [5:0]   source_exp,
input          source_valid,

output [17:0]  o_display_max_magn,
output [10:0]  o_display_max_id,

output [15:0]  o_fft_color
);
parameter   displaytime = 750000;

// for color
parameter red = 16'b1_11111_00000_00000;        //red
parameter orange = 16'b1_11111_10011_00011;
parameter yellow = 16'b1_11111_11111_00000;     // yellow
parameter green = 16'b1_00000_11111_00000;	    // green
parameter light_blue = 16'b1_00000_11111_11111;	// light blue
parameter blue = 16'b1_00000_00000_11111;	    // blue
parameter purple = 16'b1_11111_00000_11111;     // purple
parameter white = 16'b1_11111_11111_11111;   	// white
parameter black = 16'b1_00000_00000_00000;   	// black
parameter transparent = 16'b0_00000_00000_00000;


function automatic integer log2;
    input integer in;
    integer in2;
begin
    in2 = in;

    for(log2 = 0; in2 > 1; log2 = log2+1) begin
        in2 = in2>>1;
    end
end
endfunction

reg    [10:0]   length_cont_r;  //count 1024 cycle
wire   [10:0]   length_cont_w;

reg    [19:0]   fft_length_r;
wire   [19:0]   fft_length_w;
reg    [10:0]   tmp_fft_id_r;
wire   [10:0]   tmp_fft_id_w;

reg    [3:0]    fft_mode_r;
reg    [3:0]    fft_mode_w;
wire            fft_change_mode;
///////////////////////////
wire   [17:0]   source_magn;



reg    [24:0]   display_cont_r; //display every x second
wire   [24:0]   display_cont_w;

reg    [17:0]   display_max_magn_r;
wire   [17:0]   display_max_magn_w;
reg    [10:0]   display_max_id_r;
wire   [10:0]   display_max_id_w;

reg    [17:0]   max_magn_r;
wire   [17:0]   max_magn_w;
reg    [10:0]   max_id_r;
wire   [10:0]   max_id_w;

reg    [17:0]   f_max_magn_r;
wire   [17:0]   f_max_magn_w;
reg    [10:0]   f_max_id_r;
wire   [10:0]   f_max_id_w;


wire            fft_valid = (length_cont_r>11'd3 && length_cont_r<11'd128);

// shift source_exp to cordic
wire [17:0] vc_x, vc_y;
wire [3:0]  neg_exp;
assign neg_exp = (~(source_exp[3:0]))+4'd1;

assign vc_x = (source_real<<neg_exp[3:0]);//:(source_real>>>source_exp[3:0]);
assign vc_y = (source_imag<<neg_exp[3:0]);//:(source_imag>>>source_exp[3:0]);
//wire [5:0]  neg_exp={1'b0,~source_exp[4:0]}+1;

wire [16:0] source_real_ab,source_imag_ab;

assign source_real_ab = source_real[17]? ~source_real[16:0] +1 :source_real[16:0];
assign source_imag_ab = source_imag[17]? ~source_imag[16:0] +1 :source_imag[16:0];

//assign source_real_ab = vc_x[17]? ~vc_x[16:0] +1 :vc_x[16:0];
//assign source_imag_ab = vc_y[17]? ~vc_y[16:0] +1 :vc_y[16:0];

assign source_magn = {1'b0,source_real_ab}+{1'b0,source_imag_ab};
assign length_cont_w = (source_startofpacket&&source_valid) ? 1 : 
					   	   length_cont_r!=0 ? length_cont_r+1:
					   	   					  0 ;

assign display_cont_w = display_cont_r==displaytime? 0 : display_cont_r+1;

assign display_max_magn_w= display_cont_r==50? f_max_magn_r : display_max_magn_r;
assign display_max_id_w  = display_cont_r==50? f_max_id_r   : display_max_id_r;

// max function
assign max_magn_w = ~fft_valid ? 0: (source_magn>max_magn_r && fft_valid) ? source_magn    : max_magn_r;
assign max_id_w   = ~fft_valid ? 0: (source_magn>max_magn_r && fft_valid) ? length_cont_r  : max_id_r;

assign f_max_magn_w = length_cont_r==11'd127 ? max_magn_r : f_max_magn_r;
assign f_max_id_w   = length_cont_r==11'd127 ? max_id_r   : f_max_id_r;

//fft change mode
wire   [8:0] fft_id;

assign tmp_fft_id_w = f_max_id_r;
assign fft_length_w = (f_max_id_r==tmp_fft_id_r-11'd1 || f_max_id_r==tmp_fft_id_r+11'd1 ||f_max_id_r==tmp_fft_id_r)? fft_length_r+20'd1 :0;
//assign fft_change_mode = fft_length_r > 20'd350000;
assign fft_change_mode = fft_length_r > 20'd350000;

assign fft_id = tmp_fft_id_r[8:0];
always@(*)begin
	/*if(fft_change_mode)
		if(fft_id==9'd15)
			fft_mode_w = 4'd1;
		else
			fft_mode_w = 4'd2;
	else
		fft_mode_w = 4'd4;
	*/
	if(fft_change_mode) begin
		case(fft_id)
			9'd13:fft_mode_w = 4'd0;
			9'd14:fft_mode_w = 4'd0;
			9'd15:fft_mode_w = 4'd1;
			9'd16:fft_mode_w = 4'd1;
			9'd17:fft_mode_w = 4'd2;
			9'd18:fft_mode_w = 4'd2;
			9'd19:fft_mode_w = 4'd3;
			9'd20:fft_mode_w = 4'd3;
			9'd21:fft_mode_w = 4'd4;
			9'd22:fft_mode_w = 4'd4;
			9'd23:fft_mode_w = 4'd5;
			9'd24:fft_mode_w = 4'd5;
			9'd25:fft_mode_w = 4'd6;
			9'd26:fft_mode_w = 4'd6;
			9'd27:fft_mode_w = 4'd7;
			9'd28:fft_mode_w = 4'd7;
			9'd29:fft_mode_w = 4'd8;
			9'd30:fft_mode_w = 4'd8;
			9'd31:fft_mode_w = 4'd9;
			9'd32:fft_mode_w = 4'd9;
		default:fft_mode_w = 4'b1111;
		endcase // tmp_fft_id_r
	end
	else
		fft_mode_w = fft_mode_r;

end
reg  [15:0] fft_color_w, fft_color_r;
always@(*)begin
/*	if(fft_mode_r==4'd1)
		o_fft_color = red;
	else
		o_fft_color = black;
*/	
	case (fft_mode_r)
		4'd0: fft_color_w = red;
		4'd1: fft_color_w = orange;
		4'd2: fft_color_w = yellow;
		4'd3: fft_color_w = green;
		4'd4: fft_color_w = light_blue;
		4'd5: fft_color_w = blue;
		4'd6: fft_color_w = purple;
		4'd7: fft_color_w = white;
		4'd8: fft_color_w = black;
		4'd9: fft_color_w = transparent;
		default :  fft_color_w = black;
	endcase
end

assign o_fft_color = fft_color_r;

//display every second
assign o_display_max_magn= display_max_magn_r;
assign o_display_max_id  = display_max_id_r;

always @(posedge clk) begin : proc_wait_cont_r
	if(~rst_n) begin
		length_cont_r <= 0;		
		display_cont_r<= 0;
		display_max_magn_r<=0;
		display_max_id_r<=0;

		max_magn_r    <=0;
		max_id_r      <=0;
		f_max_magn_r  <=0;
		f_max_id_r    <=0;

		fft_length_r  <=0;
		tmp_fft_id_r  <=0;
		fft_mode_r    <=4'd15;
		fft_color_r   <=0;
	end else begin
		length_cont_r <= length_cont_w;
		display_cont_r    <= display_cont_w;
		display_max_magn_r<= display_max_magn_w;
		display_max_id_r  <= display_max_id_w;
		
		max_magn_r    <= max_magn_w;
		max_id_r      <= max_id_w;
		f_max_magn_r  <= f_max_magn_w;
		f_max_id_r    <= f_max_id_w;

		fft_length_r  <= fft_length_w;
		tmp_fft_id_r  <= tmp_fft_id_w;
		fft_mode_r    <= fft_mode_w;
		fft_color_r   <= fft_color_w;
	end
end

endmodule



