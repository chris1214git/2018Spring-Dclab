module I2S_test(
	input i_daclrck,
	input i_adclrck,
	input i_bclk,
	input i_rst,
	input [1:0] o_mem_action,   //tell I2S it's time to write(0) read(1) or echo(2)
	input init_finish,				//tell I2S it can start transmitting data
	input i_adcdat,		//input data from WM8731 one bit per cycle
	input [15:0] o_data,		//input data from SRAM one bit per cycle
	output reg o_dacdat
);
	
	localparam MEM_WRITE = 0;
	localparam MEM_READ = 1;
	localparam MEM_ECHO = 2;
	
	localparam S_INIT = 0;
localparam S_LEFT = 1;
localparam S_RIGHT = 2;

localparam CHANNEL_LENGTH = 16;

logic [2:0] state_r, state_w;
logic [15:0] data_r, data_w;
logic [10:0] clk_r, clk_w;



	task audio;
begin
	if (clk_r > 0) begin
		case(o_mem_action)
			MEM_READ: begin
				o_dacdat = o_data[clk_r - 1];
			end
			MEM_WRITE: begin
				data_w = (data_r << 1) + i_adcdat;
			end
			MEM_ECHO: begin
				o_dacdat = i_adcdat;
			end
		endcase
		clk_w = clk_r - 1;
	end
end
endtask

always_comb begin
	state_w = state_r;
	clk_w = clk_r;
	o_dacdat = 0;
	data_w = data_r;
	case(state_r)
		S_INIT: begin
			if (init_finish) begin
				clk_w = CHANNEL_LENGTH;
				data_w = 0;
				state_w = S_LEFT;
			end
		end
		S_LEFT: begin
			if (i_adclrck) begin
				clk_w = CHANNEL_LENGTH;
				data_w = 0;
				state_w = S_RIGHT;
			end
			audio();
			
		end
		S_RIGHT: begin
			if (!i_adclrck) begin
				clk_w = CHANNEL_LENGTH;
				data_w = 0;
				state_w = S_LEFT;
			end
			audio();
		end
	endcase
end

always_ff @(negedge i_bclk or negedge i_rst) begin
	if (!i_rst) begin
		state_r <= S_INIT;
		data_r <= 0;
		clk_r <= 0;
	end
	else if (!i_bclk) begin
		state_r <= state_w;
		clk_r <= clk_w;
		data_r <= data_w;
	end
end
endmodule