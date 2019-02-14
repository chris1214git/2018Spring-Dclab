module slow_cal (
	input [15:0] i_data1,
	input [15:0] i_data2,
	input [2:0] i_count_inter,
	input [3:0] i_speed,
	input i_mode,			// 0 for piecewise-constant ; 1 for linear interpolation
	output reg [15:0] o_data
);

always_comb begin
	if(i_mode==1) begin
			case (i_speed)
				0 : o_data = $signed(i_data1) + ((($signed(i_data2) - $signed(i_data1)) * $signed({1'b0 , i_count_inter})) >>> 3);
				1 : o_data = $signed(i_data1) + ((($signed(i_data2) - $signed(i_data1)) * $signed({1'b0 , i_count_inter})) / 4'sd7);
				2 : o_data = $signed(i_data1) + ((($signed(i_data2) - $signed(i_data1)) * $signed({1'b0 , i_count_inter})) / 4'sd6);
				3 : o_data = $signed(i_data1) + ((($signed(i_data2) - $signed(i_data1)) * $signed({1'b0 , i_count_inter})) / 4'sd5);
				4 : o_data = $signed(i_data1) + ((($signed(i_data2) - $signed(i_data1)) * $signed({1'b0 , i_count_inter})) >>> 2);
				5 : o_data = $signed(i_data1) + ((($signed(i_data2) - $signed(i_data1)) * $signed({1'b0 , i_count_inter})) / 4'sd3);
				6 : o_data = $signed(i_data1) + ((($signed(i_data2) - $signed(i_data1)) * $signed({1'b0 , i_count_inter})) >>> 1);
				default : o_data = $signed(i_data1);
			endcase
	end
	else begin
		o_data = $signed(i_data1);
	end
end
endmodule