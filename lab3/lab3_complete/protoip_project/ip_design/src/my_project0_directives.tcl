############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
############################################################
set_directive_interface -mode m_axi -depth 120 "foo" memory_inout
set_directive_interface -mode s_axilite -bundle BUS_A "foo"
set_directive_interface -mode s_axilite -register -bundle BUS_A "foo" byte_x_hat_in_offset
set_directive_interface -mode s_axilite -register -bundle BUS_A "foo" byte_u_opt_out_offset
set_directive_inline -off "foo_user"
set_directive_pipeline "foo/input_cast_loop_x_hat"
set_directive_pipeline "foo/output_cast_loop_u_opt"


