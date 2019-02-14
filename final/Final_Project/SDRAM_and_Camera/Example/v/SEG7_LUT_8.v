// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
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
// Major Functions:	SEG7_LUT_8
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN        :| 07/07/09  :| Initial Revision
// --------------------------------------------------------------------

module SEG7_LUT_8 (	oSEG0,oSEG1,oSEG2,oSEG3,oSEG4,oSEG5,oSEG6,oSEG7,iDIG,check,s1,s2,s3,s4 );
input	[31:0]	iDIG;
input           check;
input   [5:0]   s1;
input   [5:0]   s2;
input   [5:0]   s3;
input   [5:0]   s4;
output	[6:0]	oSEG0,oSEG1,oSEG2,oSEG3,oSEG4,oSEG5,oSEG6,oSEG7;

SEG7_LUT	u0	(	oSEG0,iDIG[3:0]		);
SEG7_LUT	u1	(	oSEG1,iDIG[7:4]		);
SEG7_LUT	u2	(	oSEG2,{1'b0,s4[2:0]} 	);
SEG7_LUT	u3	(	oSEG3,{1'b0,s4[5:3]} 	);
SEG7_LUT	u4	(	oSEG4,{1'b0,s1[2:0]} 	);
SEG7_LUT	u5	(	oSEG5,{1'b0,s1[5:3]}  	);
SEG7_LUT	u6	(	oSEG6,{1'b0,s2[2:0]} 	);
SEG7_LUT	u7	(	oSEG7,{1'b0,s2[5:3]}	);

endmodule