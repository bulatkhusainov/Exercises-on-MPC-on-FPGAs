// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (lin64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Mon Apr  3 17:43:27 2017
// Host        : bkhusain-HP-Z420-Workstation running 64-bit Ubuntu 14.04.5 LTS
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               /home/bkhusain/hdrive/bulat_documents/events_conferences/Slovakia_summer_school/lab1/lab1_complete/lab1_complete.sim/sim_1/impl/timing/lab1_tb_time_impl.v
// Design      : lab1
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* ECO_CHECKSUM = "8c74bdbb" *) 
(* NotValidForBitStream *)
module lab1
   (\input ,
    \output );
  input [1:0]\input ;
  output [1:0]\output ;

  wire [1:0]\input ;
  wire [1:0]\output ;
  wire \output[1]_INST_0_i_2_n_0 ;
  wire [1:0]output_OBUF;

initial begin
 $sdf_annotate("lab1_tb_time_impl.sdf",,,,"tool_control");
end
  OBUF \output[0]_INST_0 
       (.I(output_OBUF[0]),
        .O(\output [0]));
  IBUF \output[0]_INST_0_i_1 
       (.I(\input [0]),
        .O(output_OBUF[0]));
  OBUF \output[1]_INST_0 
       (.I(output_OBUF[1]),
        .O(\output [1]));
  LUT1 #(
    .INIT(2'h1)) 
    \output[1]_INST_0_i_1 
       (.I0(\output[1]_INST_0_i_2_n_0 ),
        .O(output_OBUF[1]));
  IBUF \output[1]_INST_0_i_2 
       (.I(\input [1]),
        .O(\output[1]_INST_0_i_2_n_0 ));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
