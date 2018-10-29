module Rsa256Core(
	input i_clk,
	input i_rst,
	input i_start,
	input [255:0] i_a,
	input [255:0] i_e,
	input [255:0] i_n,
	output [255:0] o_a_pow_e,
	output o_finished
);
	//combinational 
	logic [256:0] t_m;
	logic waiting_MOP;
	logic done_MOP;
	logic [255:0] ret_w;
	logic done_w;
	
	//sequential 
	logic done_r;
	logic [255:0] ret_r;
	
	assign o_a_pow_e = ret_r;
	assign o_finished = done_r;
	
	MOP MOP0 (.i_clk(i_clk), .i_rst(i_rst), .i_start(i_start), .a({1'b0 , i_a}), .b({1'b1, 256'd0}), .n(i_n), .m(t_m), .waiting(waiting_MOP), .done(done_MOP));
	FastPow FastPow0 (.i_clk(i_clk), .i_rst(i_rst), .i_start(done_MOP), .y(t_m[255:0]), .d(i_e), .N(i_n), .out_x(ret_w), .done(done_w));
	
	always_ff @ (posedge i_clk) begin
		if(i_rst) begin
			ret_r <= 0;
			done_r <= 0;
		end
		else begin
			ret_r <= ret_w;
			done_r <= done_w;
		end
	end
	
endmodule

module FastPow(
	input i_clk,
	input i_rst,
	input i_start,
	input [255:0] y,
	input [255:0] d,
	input [255:0] N, 
	output [255:0] out_x,    // out_x=y^d (mod N)
	output done
);

	//combinational 
	logic [8:0] i_w;
	logic [256:0] t_w;
	logic [256:0] ret_w;
	logic M1_done;
	logic M2_done;
	logic M1_start_w;
	logic M2_start_w;
	logic M1_wait;
	logic M2_wait;
	logic waiting_w;
	logic [255:0] out_w;
	
	//sequential 
	logic [8:0] i_r;
	logic [256:0] t_r;
	logic [256:0] t;
	logic [256:0] ret_r;
	logic [256:0] ret;
	logic waiting_r;
	logic [255:0] d_r;
	logic [255:0] N_r;
	logic [255:0] out_r;
	logic M1_start_r;
	logic M2_start_r;
	
	assign out_w = (done && waiting_r) ? ret_r[255:0] : out_r;
	assign out_x = out_w;
	assign waiting_w = (done) ? 0 : waiting_r;
	assign done = ((i_r == 256) && waiting_r) ? 1 : 0;
	
	Mont M1(.i_clk(i_clk) ,.i_rst(i_rst) ,.i_start(M1_start_r) ,.a(ret_r) ,.b(t_r) ,.n(N_r) ,.m(ret_w) , .waiting(M1_wait) , .done(M1_done));
	Mont M2(.i_clk(i_clk) ,.i_rst(i_rst) ,.i_start(M2_start_r) ,.a(t_r) ,.b(t_r) ,.n(N_r) ,.m(t_w) , .waiting(M2_wait), .done(M2_done));
	
	always_comb begin
		i_w = (M2_done) ? (i_r + 1) : i_r;
		ret = (M1_done) ? ret_w : ret_r;
		t = (M2_done) ? t_w : t_r;
		M1_start_w = (!M1_wait && d_r[i_r] && waiting_r) ? 1 : 0;
		M2_start_w = (!M2_wait) ? 1 : 0;
	end

	always_ff @ (posedge i_clk) begin
		if(i_rst || i_start) begin
			i_r   <= 0;
			t_r   <= y; 
			ret_r <= 1;
			d_r   <= d;
			N_r   <= N;
			out_r <= 0;
			waiting_r <= 1;
			M1_start_r <= 1;
			M2_start_r <= 1;
		end
		else begin
			i_r   <= i_w;
			t_r   <= t;
			ret_r <= ret;
			d_r   <= d_r;
			N_r   <= N_r;
			out_r <= out_w;
			waiting_r <= waiting_w;
			M1_start_r <= M1_start_w;
			M2_start_r <= M2_start_w;
		end
	end
	
endmodule

module Mont(
	input i_clk,
	input i_rst,
	input i_start,
	input [256:0] a,
	input [256:0] b,
	input [255:0] n,
	output [256:0] m,
	output waiting,
	output done
);
	//combinational 
	logic [257:0] ret_w;
	logic [9:0] i_w;
	logic [257:0] ret_temp; 
	logic [257:0] ret_temp2;
	logic waiting_w;
	logic [256:0] m_w;
	
	//sequential 
	logic [9:0] i_r;
	logic [257:0] ret_r;
	logic waiting_r;
	logic [256:0] m_r;
	logic [256:0] a_r;
	logic [256:0] b_r;
	logic [255:0] n_r;
		
	assign i_w = i_r + 1;
	assign m_w = (done && waiting_r) ? ret_w : m_r;
	assign m = m_w[256:0];
	assign done = (waiting && (i_r == 255)) ? 1 : 0;
	assign waiting_w = (done) ? 0 : waiting_r;
	assign waiting = waiting_r;
	
	
	always_comb begin
		ret_temp =(b_r[i_r]) ? (ret_r + a_r) : ret_r;
		
		if(ret_temp[0] == 1) begin  // ret_w is odd
			ret_temp2 = (ret_temp + n_r) >> 1 ;
		end
		else begin
			ret_temp2 = ret_temp >> 1 ;
		end
			
		if((ret_temp2 >= (n_r << 1)) && (i_r == 255)) begin
			ret_w = (ret_temp2 >= (n_r << 2)) ? (ret_temp2 - (n_r << 2)) : (ret_temp2 - (n_r << 1));
		end
		else if ((ret_temp2 >= n_r) && (i_r == 255)) begin
			ret_w = ret_temp2 - n_r;
		end
		else begin
			ret_w = ret_temp2;
		end
	end
	
	always_ff @ (posedge i_clk) begin
		if (i_rst || i_start) begin
			ret_r <= 0;
			i_r   <= 0;
			m_r   <= 0;
			waiting_r <= (i_start) ? 1 : 0;
			a_r <= a;
			b_r <= b;
			n_r <= n;
		end
		else begin
			ret_r <= ret_w;
			i_r   <= i_w;
			m_r   <= m_w;
			waiting_r <= waiting_w;
			a_r <= a_r;
			b_r <= b_r;
			n_r <= n_r;
		end
	end

endmodule

module MOP(
	input i_clk,
	input i_rst,
	input i_start,
	input [256:0] a,
	input [256:0] b,		//b=2^256
	input [255:0] n,
	output [256:0] m,
	output waiting,
	output done
);
	//combinational 
	logic [258:0] t_w;
	logic [258:0] ret_w;
	logic waiting_w;
	logic [8:0] i_w;
	logic [256:0] m_w;
	
	//sequential
	logic [258:0] t_r;
	logic [258:0] ret_r;
	logic waiting_r;
	logic [8:0] i_r;
	logic [256:0] m_r;
	logic [256:0] b_r;
	logic [256:0] n_r;
	
	assign i_w = i_r + 1;
	assign m_w = (done && waiting_r) ? ret_w[256:0] : m_r;
	assign m = m_w;
	assign waiting_w = (done) ? 0 : waiting_r;
	assign waiting = waiting_r;
	assign done = (waiting && (i_r == 256)) ? 1 : 0;
	
	always_comb begin
		if(b_r[i_r] == 1) begin
			if(ret_r + t_r >= n_r) 
				ret_w = ret_r + t_r - n_r;
			else 
				ret_w = ret_r + t_r;
		end
		else ret_w = ret_r;
		if((t_r << 1) >= n_r) t_w = (t_r << 1) - n_r;
		else t_w = (t_r << 1);
	end
	
	always_ff @ (posedge i_clk) begin
		if (i_rst) begin
			ret_r <= 0;
			i_r   <= 0;
			m_r   <= 0;
			t_r <= a;
			waiting_r <= 0;
			b_r <= b;
			n_r <= n;
		end
		else if(i_start) begin
			ret_r <= 0;
			i_r   <= 0;
			m_r   <= 0;
			t_r <= a;
			waiting_r <= 1;
			b_r <= b;
			n_r <= n;
		end
		else begin
			ret_r <= ret_w;
			i_r   <= i_w;
			m_r   <= m_w;
			t_r <= t_w;
			waiting_r <= waiting_w;
			b_r <= b_r;
			n_r <= n_r;
		end
	end
	
endmodule
