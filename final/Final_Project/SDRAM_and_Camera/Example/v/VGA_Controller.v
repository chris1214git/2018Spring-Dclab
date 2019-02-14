// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	VGA_Controller
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN Peli Li:| 22/07/2010:| Initial Revision
// --------------------------------------------------------------------

module	VGA_Controller(	//	Host Side
						iRed,
						iGreen,
						iBlue,
						oRequest,
						oRequest2,
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_H_SYNC,
						oVGA_V_SYNC,
						oVGA_SYNC,
						oVGA_BLANK,
						X_Cont,
						Y_Cont,
						//	Control Signal
						iCLK,
						iRST_N,
						iZOOM_MODE_SW
							);
`include "VGA_Param.h"

`ifdef VGA_640x480p60
//	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	96;
parameter	H_SYNC_BACK	=	48;
parameter	H_SYNC_ACT	=	640;	
parameter	H_SYNC_FRONT=	16;
parameter	H_SYNC_TOTAL=	800;

//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	2;
parameter	V_SYNC_BACK	=	33;
parameter	V_SYNC_ACT	=	480;	
parameter	V_SYNC_FRONT=	10;
parameter	V_SYNC_TOTAL=	525; 

`else
 // SVGA_800x600p60
////	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	128;         //Peli
parameter	H_SYNC_BACK	=	88;
parameter	H_SYNC_ACT	=	800;	
parameter	H_SYNC_FRONT=	40;
parameter	H_SYNC_TOTAL=	1056;
//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	4;
parameter	V_SYNC_BACK	=	23;
parameter	V_SYNC_ACT	=	600;	
parameter	V_SYNC_FRONT=	1;
parameter	V_SYNC_TOTAL=	628;

`endif
//	Start Offset
parameter	X_START		=	H_SYNC_CYC+H_SYNC_BACK;
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK;
//	Host Side
input		[9:0]	iRed;
input		[9:0]	iGreen;
input		[9:0]	iBlue;
output	reg			oRequest;
output	reg			oRequest2;
//	VGA Side
output	reg	[9:0]	oVGA_R;
output	reg	[9:0]	oVGA_G;
output	reg	[9:0]	oVGA_B;
output	reg			oVGA_H_SYNC;
output	reg			oVGA_V_SYNC;
output	reg			oVGA_SYNC;
output	reg			oVGA_BLANK;

output      [12:0]  X_Cont;
output      [12:0]  Y_Cont;

wire		[9:0]	mVGA_R;
wire		[9:0]	mVGA_G;
wire		[9:0]	mVGA_B;
reg					mVGA_H_SYNC;
reg					mVGA_V_SYNC;
wire				mVGA_SYNC;
wire				mVGA_BLANK;

//	Control Signal
input				iCLK;
input				iRST_N;
input 				iZOOM_MODE_SW;

//	Internal Registers and Wires
reg		[12:0]		H_Cont;
reg		[12:0]		V_Cont;

wire	[12:0]		v_mask;

//reverse
integer i;
reg 	[9:0]   dataR_r[1023:0];
reg   	[9:0]	dataR_w[1023:0];
reg 	[9:0]   dataG_r[1023:0];
reg   	[9:0]	dataG_w[1023:0]; 
reg 	[9:0]   dataB_r[1023:0];
reg   	[9:0]	dataB_w[1023:0]; 


wire 	[12:0] buffer_count,buffer_count2,line_count;
assign  buffer_count  = 799-H_Cont+X_START;
assign  buffer_count2 = H_Cont-X_START;
assign  line_count    = V_Cont-Y_START;
wire    [9:0]  b_cont_800, b_cont2_800;
assign  b_cont_800  = buffer_count [9:0];
assign  b_cont2_800 = buffer_count2[9:0];

reg    		flag_orient_r,flag_orient_w;

always@(*) begin
	for(i=0;i<800;i=i+1)begin
		dataR_w[i] = dataR_r[i];
		dataG_w[i] = dataG_r[i];
		dataB_w[i] = dataB_r[i];
	end
	if(H_Cont>=X_START && H_Cont<(X_START+H_SYNC_ACT) ) begin
	if(flag_orient_r) begin
	dataR_w[b_cont_800] = iRed;
	dataG_w[b_cont_800] = iGreen;
	dataB_w[b_cont_800] = iBlue;
	end
	else begin
	dataR_w[b_cont2_800] = iRed;
	dataG_w[b_cont2_800] = iGreen;
	dataB_w[b_cont2_800] = iBlue;
	end
	
	end
end
wire 	[9:0] dataR_final;
wire 	[9:0] dataG_final;
wire 	[9:0] dataB_final;
assign dataR_final= flag_orient_r?dataR_r[buffer_count]:dataR_r[buffer_count2];
assign dataG_final= flag_orient_r?dataG_r[buffer_count]:dataG_r[buffer_count2];
assign dataB_final= flag_orient_r?dataB_r[buffer_count]:dataB_r[buffer_count2];

always@(*) begin
	if(line_count[0])
		flag_orient_w = 1;
	else
		flag_orient_w = 0;
end




assign v_mask = 13'd0 ;//iZOOM_MODE_SW ? 13'd0 : 13'd26;

////////////////////////////////////////////////////////

assign	mVGA_BLANK	=	mVGA_H_SYNC & mVGA_V_SYNC;
assign	mVGA_SYNC	=	1'b0;

assign	mVGA_R	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	dataR_final	:	0;
assign	mVGA_G	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	dataG_final	:	0;
assign	mVGA_B	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	dataB_final	:	0;

assign X_Cont = (H_Cont-X_START > 799)? 800:H_Cont-X_START;
assign Y_Cont = (V_Cont-Y_START > 599)? 600:V_Cont-Y_START;//-v_mask;
						
always@(posedge iCLK or negedge iRST_N)
	begin
		if (!iRST_N)
			begin
				oVGA_R <= 0;
				oVGA_G <= 0;
                oVGA_B <= 0;
				oVGA_BLANK <= 0;
				oVGA_SYNC <= 0;
				oVGA_H_SYNC <= 0;
				oVGA_V_SYNC <= 0; 
				for(i=0;i<800;i=i+1)begin
				dataR_r[i] <=0; 
				dataG_r[i] <=0; 
				dataB_r[i] <=0;
				end
				flag_orient_r <=0;
			end
		else
			begin
				oVGA_R <= mVGA_R;
				oVGA_G <= mVGA_G;
                oVGA_B <= mVGA_B;
				oVGA_BLANK <= mVGA_BLANK;
				oVGA_SYNC <= mVGA_SYNC;
				oVGA_H_SYNC <= mVGA_H_SYNC;
				oVGA_V_SYNC <= mVGA_V_SYNC;	
				for(i=0;i<800;i=i+1)begin	 
				dataR_r[i] <=dataR_w[i]; 
				dataG_r[i] <=dataG_w[i]; 
				dataB_r[i] <=dataB_w[i];	
				end
				flag_orient_r <= flag_orient_w;			
			end               
	end



//	Pixel LUT Address Generator
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N) begin
	oRequest	<=	0;
	oRequest2	<=	0;
	end
	else
	begin
		if(	H_Cont>=X_START-2 && H_Cont<X_START+H_SYNC_ACT-2 &&
			V_Cont>=Y_START && V_Cont<Y_START+V_SYNC_ACT )
		oRequest	<=	1;
		else
		oRequest	<=	0;
		if(	H_Cont>=X_START-1 && H_Cont<X_START+H_SYNC_ACT-1 &&
			V_Cont>=Y_START && V_Cont<Y_START+V_SYNC_ACT )
		oRequest2	<=	1;
		else
		oRequest2	<=	0;
	end
end

//	H_Sync Generator, Ref. 40 MHz Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		mVGA_H_SYNC	<=	0;
	end
	else
	begin
		//	H_Sync Counter
		if( H_Cont < H_SYNC_TOTAL )
		H_Cont	<=	H_Cont+1;
		else
		H_Cont	<=	0;
		//	H_Sync Generator
		if( H_Cont < H_SYNC_CYC )
		mVGA_H_SYNC	<=	0;
		else
		mVGA_H_SYNC	<=	1;
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		mVGA_V_SYNC	<=	0;
	end
	else
	begin
		//	When H_Sync Re-start
		if(H_Cont==0)
		begin
			//	V_Sync Counter
			if( V_Cont < V_SYNC_TOTAL )
			V_Cont	<=	V_Cont+1;
			else
			V_Cont	<=	0;
			//	V_Sync Generator
			if(	V_Cont < V_SYNC_CYC )
			mVGA_V_SYNC	<=	0;
			else
			mVGA_V_SYNC	<=	1;
		end
	end
end

endmodule