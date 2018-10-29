module Top(
	input i_clk,
	input i_rst,
	input i_start,
	input i_count,
	output [3:0] o_random_out
);

logic [1:0]state;
logic [1:0]state_w ;
logic [1:0]state_r ;
assign state=state_r;

logic [3:0]  random_num ;
logic [30:0] clock_counter;
logic [30:0] clock_counter2;
logic [30:0] counter_dummy_r, counter_dummy_w;
//logic [30:0] clock_counter2_w;

logic [3:0] o_random_out_r;
logic [3:0] o_random_out_w;
assign o_random_out=o_random_out_r;

logic [30:0] seed;
logic [30:0] num_r;
logic [30:0] num_w;
random random1(.seed(seed), .random_num(random_num), .num(num_w));
//assign seed=clock_counter;

always_comb begin
	case(clock_counter2)
		0: if(state!=2)
			o_random_out_w=o_random_out_r;
		   else
			o_random_out_w=counter_dummy_r;
		12500000:  o_random_out_w=random_num;
		25000000: o_random_out_w=random_num;
		50000000: o_random_out_w=random_num;
		62500000: o_random_out_w=random_num;
		75000000: o_random_out_w=random_num;
		
		100000000: o_random_out_w=random_num;
		125000000: o_random_out_w=random_num;
		150000000: o_random_out_w=random_num;
		175000000: o_random_out_w=random_num;
		250000000: o_random_out_w=random_num;
		
		325000000: o_random_out_w=random_num;
		400000000: o_random_out_w=random_num;
		475000000: o_random_out_w=random_num;
		default:
		o_random_out_w = o_random_out_r;
	endcase
end

always_comb begin
	case(state)
		0:begin
		counter_dummy_w=counter_dummy_r;
		  seed=num_r;
		  if(i_start==1)begin
			state_w=1;
			seed=clock_counter;
		  end
		  else if(i_count==1)begin		  
			state_w=2;
			end
     	  else state_w=0;
		end
		1:begin
		counter_dummy_w=0;
		  state_w=1;
		  if(clock_counter2==475000000)
			state_w=0;
		  seed=num_r;
		  if(i_start==1)begin
			state_w=1;
			seed=clock_counter;
		  end
		end
		2:begin
		  seed=num_r;
		  state_w=2;
		  counter_dummy_w=counter_dummy_r;
		  if(i_count)begin
		    counter_dummy_w=counter_dummy_r+1;
		  end
		  if(i_start)begin
			state_w=1;
			seed=counter_dummy_r;
		  end
		end
	endcase
end



/*------------------------------*/
always_ff @(posedge i_clk or negedge i_rst) begin if(!i_rst) begin
	clock_counter<=0;
	clock_counter2<=0;
	counter_dummy_r<=0;
	o_random_out_r<=0;
	state_r<=0;
	num_r<=0;
	end
	else begin
	counter_dummy_r<=counter_dummy_w;
    clock_counter <= clock_counter + 1;
	if(state==1)
		if(i_start==1)
			clock_counter2<=0;
		else if(clock_counter2==475000000)
			clock_counter2<=0;
		else
			clock_counter2<=clock_counter2+1;
	else
		clock_counter2<=0;
	state_r<=state_w;
	o_random_out_r <= o_random_out_w;
	num_r<=num_w;
	end
end

endmodule


/*------------------------------*/
module random(
	input [30:0] seed,
	output [3:0] random_num,
	output[30:0] num
);

assign num = seed * 1103515245 + 12345;
assign random_num = {num[15:14], num[3], num[13]};

endmodule