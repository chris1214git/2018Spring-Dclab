module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	//input AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
	
);
	//reset
	logic rst_n;
	// inout port at this layer
	//logic i2c_oen, i2c_sdat;
	//logic [15:0] sram_wdata;
	//assign I2C_SDAT = i2c_oen ? i2c_sdat : 1'bz;
	//assign SRAM_DQ = /* TODO */;
	
	logic key0,key1,key2,key3;
	logic clk100k;
	/* TODO: Add PLL to generate a 100kHz clock (Google is your friend) */
	
		
	logic [26:0] count_time_r, count_time_w, count_time;
	logic [5:0] time_r, time_w;
	logic [2:0] counter_r, counter_w;

	logic [32:0] debug_counter1_r, debug_counter1_w;
	assign debug_counter1_w = debug_counter1_r+1;
	logic [32:0] debug_counter2_r, debug_counter2_w;
	assign debug_counter2_w = debug_counter2_r+1;
	logic [32:0] debug_counter3_r, debug_counter3_w;
	assign debug_counter3_w = debug_counter3_r+1;
	logic [32:0] debug_counter4_r, debug_counter4_w;
	assign debug_counter4_w = debug_counter4_r+1;

	logic [3:0] sevenHex_out1,sevenHex_out2,sevenHex_out3;
	assign sevenHex_out1=debug_counter1_r[27:24];
	assign sevenHex_out2=debug_counter2_r[27:24];
	assign sevenHex_out3=debug_counter3_r[16:13];
	
	logic [2:0] debug_state;
	logic [3:0] debug_speed;
	logic [19:0] debug_sram_writeaddr;

	logic o_write_enable;
	logic o_read_enable;
	logic [2:0] o_state_test;
	/*SevenHexDecoder seven_dec0(
		.i_hex(debug_speed), //read_en
		.o_seven_ten(HEX1),
		.o_seven_one(HEX0)
	);
	SevenHexDecoder seven_dec1(
		.i_hex(debug_state), //state
		.o_seven_ten(HEX3),
		.o_seven_one(HEX2)
	);
	SevenHexDecoder seven_dec2(
		.i_hex(debug_sram_writeaddr[19:16]), //LRC
		.o_seven_ten(HEX5),
		.o_seven_one(HEX4)
	);*/
	SevenHexDecoder seven_dec3(
		.i_hex(time_r), //BCLK
		.o_seven_ten(HEX7),
		.o_seven_one(HEX6)
	);
	
	pll_qsys pll_qsys_0(
		.altpll_0_c0_clk(AUD_XCK), //  12M
		.altpll_0_c1_clk(clk100k), //  100k
		.clk_clk(CLOCK_50)         
	);

logic [32:0] count_r,count_w;
always_comb begin
	count_w =count_r;
	//if (o_state_test==7)
	if(o_read_enable)
		count_w=count_r+1;
end		
	Debounce deb0(
	.i_in(KEY[0]),
	.i_rst(SW[2]),
	.i_clk(AUD_BCLK),
	.o_neg(key0)
	);
	Debounce deb1(
	.i_in(KEY[1]),
	.i_rst(SW[2]),
	.i_clk(AUD_BCLK),
	.o_neg(key1)
	);
	Debounce deb2(
	.i_in(KEY[2]),	
	.i_rst(SW[2]),
	.i_clk(AUD_BCLK),
	.o_neg(key2)
	);
	Debounce deb3(
	.i_in(KEY[3]),
	.i_rst(SW[2]),
	.i_clk(AUD_BCLK),
	.o_neg(key3)
	);
	
	Debounce rst(
	.i_in(SW[17]),
	.i_rst(SW[2]),
	.i_clk(AUD_BCLK),
	.o_neg(rst_n)
	);
	
	
always_ff @(posedge AUD_ADCLRCK or negedge SW[2])begin if(!SW[2]) begin
	debug_counter4_r<=0;
	end
	else begin
	debug_counter4_r<= debug_counter4_w;
	end
end

always_ff @(posedge AUD_BCLK or negedge SW[2])begin if(!SW[2]) begin
	debug_counter1_r<=0;
	count_r<=0;
	end
	else begin
	count_r<=count_w;
	debug_counter1_r<= debug_counter1_w;
	end
end

always_ff @(posedge AUD_XCK or negedge SW[2])begin if(!SW[2]) begin
	debug_counter2_r<=0;
	end
	else begin
	debug_counter2_r<= debug_counter2_w;
	end
end

always_ff @(posedge clk100k or negedge SW[2])begin if(!SW[2]) begin
	debug_counter3_r<=0;
	end
	else begin
	debug_counter3_r<= debug_counter3_w;
	end
end

localparam IDLE = 0, PLAY = 1, PLAY_s = 2, RECORD = 3, RECORD_s = 4;

always_comb begin
	case (debug_state)
		IDLE : begin
			count_time_w = 0;
			time_w       = 0;
		end
		PLAY_s, RECORD_s : begin
			count_time_w = count_time_r;
			time_w       = time_r;
		end
		PLAY : begin
			count_time_w = (count_time_r < 50000000) ? count_time : 0;
			time_w       = (count_time_r < 50000000) ? time_r : (time_r + 1);
		end
		RECORD : begin
			count_time_w = (count_time_r < 50000000) ? (count_time_r + 1) : 0;
			time_w       = (count_time_r < 50000000) ? time_r : (time_r + 1);
		end
		default : begin
			count_time_w = 0;
			time_w       = 0;
		end
	endcase
end

always_comb begin
	case (debug_speed)
		0 : begin
			counter_w  = (counter_r < 7) ? (counter_r + 1) : 0;
			count_time = (counter_r == 7) ? (count_time_r + 1) : count_time_r;
		end
		1 : begin
			counter_w  = (counter_r < 6) ? (counter_r + 1) : 0;
			count_time = (counter_r == 6) ? (count_time_r + 1) : count_time_r;
		end
		2 : begin
			counter_w  = (counter_r < 5) ? (counter_r + 1) : 0;
			count_time = (counter_r == 5) ? (count_time_r + 1) : count_time_r;
		end
		3 : begin
			counter_w  = (counter_r < 4) ? (counter_r + 1) : 0;
			count_time = (counter_r == 4) ? (count_time_r + 1) : count_time_r;
		end
		4 : begin
			counter_w  = (counter_r < 3) ? (counter_r + 1) : 0;
			count_time = (counter_r == 3) ? (count_time_r + 1) : count_time_r;
		end
		5 : begin
			counter_w  = (counter_r < 2) ? (counter_r + 1) : 0;
			count_time = (counter_r == 2) ? (count_time_r + 1) : count_time_r;
		end
		6 : begin
			counter_w  = (counter_r < 1) ? (counter_r + 1) : 0;
			count_time = (counter_r == 1) ? (count_time_r + 1) : count_time_r;
		end
		7 : begin
			counter_w = 0;
			count_time = count_time_r + 1;
		end
		8 : begin
			counter_w = 0;
			count_time = count_time_r + 2;
		end
		9 : begin
			counter_w = 0;
			count_time = count_time_r + 3;
		end
		10: begin
			counter_w = 0;
			count_time = count_time_r + 4;
		end
		11: begin
			counter_w = 0;
			count_time = count_time_r + 5;
		end
		12: begin
			counter_w = 0;
			count_time = count_time_r + 6;
		end
		13: begin
			counter_w = 0;
			count_time = count_time_r + 7;
		end
		14: begin
			counter_w = 0;
			count_time = count_time_r + 8;
		end
		default : begin
			counter_w = 0;
			count_time = count_time_r + 1;
		end
	endcase
end

always_ff @(posedge CLOCK_50 or negedge SW[2])begin 
	if(!SW[2]) begin
		time_r       <= 0;
		count_time_r <= 0;
		counter_r    <= 0;
	end else begin
		time_r       <= time_w;
		count_time_r <= count_time_w;
		counter_r    <= counter_w;
	end
end
	
	
	
	Top top0(.i_clk12M(AUD_BCLK),//12M
	.i_clk100k(clk100k),
	.i_key0(key0),
	.i_key1(key1),
	.i_key2(key2),
	.i_key3(key3),
	.i_sw_rec(SW[0]),// rec=0 play=1
	.i_sw_intp(SW[1]),// zero=0 interpolation=1
	.i_sw_rst(SW[2]),// reset=0 
	.SRAM_ADDR(SRAM_ADDR), //[19:0]
	.SRAM_DQ(SRAM_DQ),  //[15:0]
	.SRAM_CE_N(SRAM_CE_N),
	.SRAM_LB_N(SRAM_LB_N),
	.SRAM_OE_N(SRAM_OE_N),
	.SRAM_UB_N(SRAM_UB_N),
	.SRAM_WE_N(SRAM_WE_N),
	///////////////////////////////////
	.o_sclk(I2C_SCLK),
	.o_sdat(I2C_SDAT),
	.i_daclrc(AUD_DACLRCK),
	.i_adclrc(AUD_ADCLRCK),
	.i_bclk(AUD_BCLK),
	.i_rst(rst_n),
	.i_adc_data(AUD_ADCDAT),
	.o_dac_data(AUD_DACDAT),
	.LCD_DATA(LCD_DATA),
	.LCD_EN(LCD_EN),
	.LCD_ON(LCD_ON),
	.LCD_RS(LCD_RS),
	.LCD_RW(LCD_RW),
	.debug_speed(debug_speed),
	.debug_state(debug_state),
	.o_write_enable(o_write_enable),
	.o_read_enable(o_read_enable),
	.o_state_test(o_state_test),
	.debug_sram_writeaddr(debug_sram_writeaddr)
	);
	
	
	
	
	/*
	I2CSender u_i2c(
		// .i_clk(pll_clk),
		.i_rst(KEY[0]),
		.o_sclk(I2C_SCLK),
		.o_sdat(i2c_sdat),
		// you are outputing (you are not outputing only when you are "ack"ing.)
		.o_oen(i2c_oen)
	);
	// And add your module here, it roughly looks like this
	YourModule u_your_module(
		.i_clk(AUD_BCLK),
		.i_rst(KEY[0]),
		.i_adc_dat(AUD_ADCDAT),
		.i_adc_clk(AUD_ADCLRCK),
		.o_dac_dat(AUD_DACDAT),
		.i_dac_clk(AUD_DACLRCK),
		.o_sram_adr(SRAM_ADDR),
		.o_sram_rdata(SRAM_DQ),
		.i_sram_wdata(sram_wdata),
		.o_sram_cen(SRAM_CE_N),
		.o_sram_lb(SRAM_LB_N),
		.o_sram_ue(SRAM_UB_N),
		.o_sram_oe(SRAM_OE_N),
		.o_sram_we(SRAM_WE_N)
	);
	*/
endmodule
