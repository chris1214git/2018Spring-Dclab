module vector_cordic(clk, rst, x_in, y_in, magnitude);
	input clk, rst;
	input 	signed 	[15:0] x_in, y_in;
	output 	[15:0] magnitude;
	
	//wire or reg declaration
	
	
	reg	signed 	[19:0] x_mux[15:0], y_mux[15:0];
	reg signed  [19:0] x_in_r, y_in_r;
	reg signed  [19:0] x_w[15:0], y_w[15:0];
	reg signed  [19:0] x_r[15:0], y_r[15:0];
	
	
	wire signed [19:0] x_in2,y_in2;
	assign x_in2 = {x_in,4'b0};
	assign y_in2 = {y_in,4'b0};
	
	assign magnitude = x_r[15][19:4];
	
	integer i;
	
	//combinational circuit
	always @(*) begin
		//stage 1
		if(x_in_r[19]==0&&y_in_r[19]==0) begin		//the 1st quadrant
			x_mux[0] = x_in_r;
			y_mux[0] = y_in_r;
		end
		else if(x_in_r[19]==1&&y_in_r[19]==0) begin	//the 2nd quadrant
			x_mux[0] = y_in_r;
			y_mux[0] = ~x_in_r + 1;
		end
		else if(x_in_r[19]==1&&y_in_r[19]==1) begin	//the 3rd quadrant
			x_mux[0] = ~y_in_r + 1;
			y_mux[0] = x_in_r;
		end
		else begin								//the 4th quadrant
			x_mux[0] = x_in_r;
			y_mux[0] = y_in_r;
		end
		
		
		if(y_mux[0][19]==1) begin
			x_w[0] = x_mux[0] - (y_mux[0] >>> 0);
			y_w[0] = y_mux[0] + (x_mux[0] >>> 0);
		end
		else begin
			x_w[0] = x_mux[0] + (y_mux[0] >>> 0);
			y_w[0] = y_mux[0] - (x_mux[0] >>> 0);
		end
		
		//stage 2
		x_mux[1] = x_r[0];
		y_mux[1] = y_r[0];
		
		if(y_mux[1][19]==1) begin
			x_w[1] = x_mux[1] - (y_mux[1] >>> 1);
			y_w[1] = y_mux[1] + (x_mux[1] >>> 1);
		end
		else begin
			x_w[1] = x_mux[1] + (y_mux[1] >>> 1);
			y_w[1] = y_mux[1] - (x_mux[1] >>> 1);
		end
		
		//stage 3
		x_mux[2] = x_r[1];
		y_mux[2] = y_r[1];
		
		if(y_mux[2][19]==1) begin
			x_w[2] = x_mux[2] - (y_mux[2] >>> 2);
			y_w[2] = y_mux[2] + (x_mux[2] >>> 2);
		end
		else begin
			x_w[2] = x_mux[2] + (y_mux[2] >>> 2);
			y_w[2] = y_mux[2] - (x_mux[2] >>> 2);
		end
		
		//stage 4
		x_mux[3] = x_r[2];
		y_mux[3] = y_r[2];
		
		if(y_mux[3][19]==1) begin
			x_w[3] = x_mux[3] - (y_mux[3] >>> 3);
			y_w[3] = y_mux[3] + (x_mux[3] >>> 3);
		end
		else begin
			x_w[3] = x_mux[3] + (y_mux[3] >>> 3);
			y_w[3] = y_mux[3] - (x_mux[3] >>> 3);
		end
		
		//stage 5
		x_mux[4] = x_r[3];
		y_mux[4] = y_r[3];
		
		if(y_mux[4][19]==1) begin
			x_w[4] = x_mux[4] - (y_mux[4] >>> 4);
			y_w[4] = y_mux[4] + (x_mux[4] >>> 4);
		end
		else begin
			x_w[4] = x_mux[4] + (y_mux[4] >>> 4);
			y_w[4] = y_mux[4] - (x_mux[4] >>> 4);
		end
		
		//stage 6
		x_mux[5] = x_r[4];
		y_mux[5] = y_r[4];
		
		if(y_mux[5][19]==1) begin
			x_w[5] = x_mux[5] - (y_mux[5] >>> 5);
			y_w[5] = y_mux[5] + (x_mux[5] >>> 5);
		end
		else begin
			x_w[5] = x_mux[5] + (y_mux[5] >>> 5);
			y_w[5] = y_mux[5] - (x_mux[5] >>> 5);
		end
		
		//stage 7
		x_mux[6] = x_r[5];
		y_mux[6] = y_r[5];
		
		if(y_mux[6][19]==1) begin
			x_w[6] = x_mux[6] - (y_mux[6] >>> 6);
			y_w[6] = y_mux[6] + (x_mux[6] >>> 6);
		end
		else begin
			x_w[6] = x_mux[6] + (y_mux[6] >>> 6);
			y_w[6] = y_mux[6] - (x_mux[6] >>> 6);
		end
		
		//stage 8
		x_mux[7] = x_r[6];
		y_mux[7] = y_r[6];
		
		if(y_mux[7][19]==1) begin
			x_w[7] = x_mux[7] - (y_mux[7] >>> 7);
			y_w[7] = y_mux[7] + (x_mux[7] >>> 7);
		end
		else begin
			x_w[7] = x_mux[7] + (y_mux[7] >>> 7);
			y_w[7] = y_mux[7] - (x_mux[7] >>> 7);
		end
		
		//stage 9
		x_mux[8] = x_r[7];
		y_mux[8] = y_r[7];
		
		if(y_mux[8][19]==1) begin
			x_w[8] = x_mux[8] - (y_mux[8] >>> 8);
			y_w[8] = y_mux[8] + (x_mux[8] >>> 8);
		end
		else begin
			x_w[8] = x_mux[8] + (y_mux[8] >>> 8);
			y_w[8] = y_mux[8] - (x_mux[8] >>> 8);
		end
		
		//stage 10
		x_mux[9] = x_r[8];
		y_mux[9] = y_r[8];
		
		if(y_mux[9][19]==1) begin
			x_w[9] = x_mux[9] - (y_mux[9] >>> 9);
			y_w[9] = y_mux[9] + (x_mux[9] >>> 9);
		end
		else begin
			x_w[9] = x_mux[9] + (y_mux[9] >>> 9);
			y_w[9] = y_mux[9] - (x_mux[9] >>> 9);
		end
		
		//stage 11
		x_mux[10] = x_r[9];
		y_mux[10] = y_r[9];
		
		if(y_mux[10][19]==1) begin
			x_w[10] = x_mux[10] - (y_mux[10] >>> 10);
			y_w[10] = y_mux[10] + (x_mux[10] >>> 10);
		end
		else begin
			x_w[10] = x_mux[10] + (y_mux[10] >>> 10);
			y_w[10] = y_mux[10] - (x_mux[10] >>> 10);
		end
		
		//stage 12
		x_mux[11] = x_r[10];
		y_mux[11] = y_r[10];
		
		if(y_mux[11][19]==1) begin
			x_w[11] = x_mux[11] - (y_mux[11] >>> 11);
			y_w[11] = y_mux[11] + (x_mux[11] >>> 11);
		end
		else begin
			x_w[11] = x_mux[11] + (y_mux[11] >>> 11);
			y_w[11] = y_mux[11] - (x_mux[11] >>> 11);
		end		
		//stage 13
		x_mux[12] = x_r[11];
		y_mux[12] = y_r[11];
		
		if(y_mux[12][19]==1) begin
			x_w[12] = x_mux[12] - (y_mux[12] >>> 12);
			y_w[12] = y_mux[12] + (x_mux[12] >>> 12);
		end
		else begin
			x_w[12] = x_mux[12] + (y_mux[12] >>> 12);
			y_w[12] = y_mux[12] - (x_mux[12] >>> 12);
		end		
		//stage 14
		x_mux[13] = x_r[12];
		y_mux[13] = y_r[12];
		
		if(y_mux[13][19]==1) begin
			x_w[13] = x_mux[13] - (y_mux[13] >>> 13);
			y_w[13] = y_mux[13] + (x_mux[13] >>> 13);
		end
		else begin
			x_w[13] = x_mux[13] + (y_mux[13] >>> 13);
			y_w[13] = y_mux[13] - (x_mux[13] >>> 13);
		end		
		//stage 15
		x_mux[14] = x_r[13];
		y_mux[14] = y_r[13];
		
		if(y_mux[14][19]==1) begin
			x_w[14] = x_mux[14] - (y_mux[14] >>> 14);
			y_w[14] = y_mux[14] + (x_mux[14] >>> 14);
		end
		else begin
			x_w[14] = x_mux[14] + (y_mux[14] >>> 14);
			y_w[14] = y_mux[14] - (x_mux[14] >>> 14);
		end		
		//stage 16
		x_mux[15] = x_r[14];
		y_mux[15] = y_r[14];
		
		if(y_mux[15][19]==1) begin
			x_w[15] = x_mux[15] - (y_mux[15] >>> 15);
			y_w[15] = y_mux[15] + (x_mux[15] >>> 15);
		end
		else begin
			x_w[15] = x_mux[15] + (y_mux[15] >>> 15);
			y_w[15] = y_mux[15] - (x_mux[15] >>> 15);
		end
	end
	
	//sequential circuit
	always@ (posedge clk) begin
		if(~rst) begin
			x_in_r <= 0;
			y_in_r <= 0;
			for(i=0;i<16;i=i+1) begin
			x_r[i] <= 0;
			y_r[i] <= 0;
			end
		end
		else begin
			x_in_r <= x_in2;
			y_in_r <= y_in2;
			for(i=0;i<16;i=i+1) begin
			x_r[i] <= x_w[i];
			y_r[i] <= y_w[i];
			end
		end
	end
endmodule


