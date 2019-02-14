module I2S(
	input i_DACLRC,
	input i_ADCLRC,
	input i_BCLK,
	input i_rst,
	input [2:0] i_state_WRE,   //tell I2S it's time to write(0) read(1) or echo(2)
	input i_start,				//tell I2S it can start transmitting data
	input i_adc_data,		//input data from WM8731 one bit per cycle
	input [15:0] i_dac_data,		//input data from SRAM one bit per cycle
	input i_sram_read,				//tell I2S the data can be read from SRAM
	output [15:0] o_data_write,		//output to SRAM ; 16 bits at one time
	output o_sram_write,			//tell SRAM the data can be written
	output o_sram_read,				//tell SRAM the data should be read
	output reg o_dac_data,
	output [2:0] state_test
);

	localparam S_IDLE = 0;
	localparam S_LEFT = 1;
	localparam S_RIGHT = 2;
	
	localparam WRITE = 3;
	localparam READ = 1;
	localparam ECHO = 5;
	
	//logic o_dac_data;		//output wire to reg
	
	logic [2:0] state_w, state_r;	//S_IDLE S_LEFT S_RIGHT
	logic [15:0] I2S_data_w, I2S_data_r;   //register to store input data
	logic [4:0] num_count_w, num_count_r;  //count 16 cycles
	logic flag_read_w, flag_read_r;
	

	assign o_sram_write = (i_state_WRE==WRITE && num_count_r==16 && state_r == S_LEFT) ? 1 : 0;
	assign o_sram_read = (i_state_WRE==READ && num_count_r==17 && state_r==S_RIGHT && flag_read_r != 1) ? 1 : 0;   //flag_read_r to ensure o_sram_read is one cycle
	assign o_data_write = I2S_data_r;
	
	assign state_test = num_count_r;
	task execute;
	begin
		if(num_count_r<=15) begin
			case (i_state_WRE)
				WRITE : I2S_data_w = (I2S_data_r << 1) + i_adc_data;
				READ : o_dac_data = I2S_data_r[15-num_count_r];
				ECHO : o_dac_data = i_adc_data;
				default ;
			endcase
			num_count_w = num_count_r + 1;
		end
		else if (num_count_r == 16) num_count_w = num_count_r + 1; //control o_sram_write = 1 cycle only
		else num_count_w = num_count_r;
	end
	endtask

	always_comb begin
		o_dac_data = 0;                //if we don't set the value, keep it = 0 all the time
		state_w = state_r;
		num_count_w = num_count_r;
		if(i_sram_read==1) begin
			I2S_data_w = i_dac_data;
		end
		else begin
			I2S_data_w = I2S_data_r;
		end
		if (o_sram_read == 1) flag_read_w = 1;
		else if (num_count_r == 0) flag_read_w = 0;
		else flag_read_w = flag_read_r;
		
		
		case (state_r)
			S_IDLE : begin
				if(i_start==1) begin	//Assume after initiating, LRC is always low first.
					state_w = S_LEFT;
					I2S_data_w = I2S_data_r;
					num_count_w = num_count_r;
				
				end
				else begin
					state_w = S_IDLE;
					I2S_data_w = I2S_data_r;
					num_count_w = num_count_r;
				end
			end
			S_LEFT : begin
				if(i_state_WRE == WRITE) begin
					if(i_ADCLRC==1) begin	//change to right channel
						num_count_w = 0;	//to initiate for right channel
						I2S_data_w = I2S_data_r;
						state_w = S_RIGHT;
					end
					else begin
						execute;
						state_w = state_r;
					end
				end
				else if (i_state_WRE==READ) begin
					//I2S_data_w = i_dac_data;
					if(i_ADCLRC==1) begin	//change to right channel
						num_count_w = 0;	//to initiate for right channel
						I2S_data_w = I2S_data_r;
						state_w = S_RIGHT;
					end
					else begin
						execute;
						state_w = state_r;
					end
				end
				else if(i_state_WRE==ECHO) begin
					if(i_ADCLRC==1) begin	//change to right channel
						num_count_w = 0;	//to initiate for right channel
						I2S_data_w = I2S_data_r;
						state_w = S_RIGHT;
					end
					else begin
						execute;
						state_w = state_r;
					end
				end
				else ; 
			end	
			S_RIGHT : begin
				if(i_state_WRE == WRITE) begin
					if(i_ADCLRC==0) begin	//change to LEFT channel
						num_count_w = 0;	//to initiate for LEFT channel
						I2S_data_w = 0;
						state_w = S_LEFT;
					end
					else begin
						execute;			//Right channel doesn't need to write data
						state_w = state_r;
					end
				end
				else if (i_state_WRE==READ) begin
					if(i_ADCLRC==0) begin	//change to LEFT channel
						num_count_w = 0;	//to initiate for LEFT channel
						//I2S_data_w = i_dac_data;	//************************************************
						state_w = S_LEFT;
					end
					else begin
						execute;
						state_w = state_r;
					end
				end
				else if(i_state_WRE==ECHO) begin
					if(i_ADCLRC==0) begin	//change to LEFT channel
						num_count_w = 0;	//to initiate for LEFT channel
						I2S_data_w = 0;
						state_w = S_LEFT;
					end
					else begin
						execute;
						state_w = state_r;
					end
				end
				else ; 
			end
			default;
		endcase
	end


	always_ff @(negedge i_BCLK) begin
		if (!i_rst) begin
			state_r <= S_IDLE;
			I2S_data_r <= 0;
			num_count_r <= 0;
			flag_read_r <= 0;
		end
		else begin
			state_r <= state_w;
			I2S_data_r <= I2S_data_w;
			num_count_r <= num_count_w;
			flag_read_r <= flag_read_w;
		end
	end
endmodule