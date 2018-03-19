

% define interfaces for FPGA implementation
x_hat_in = strcat('x_hat:',num2str(design.n_states),':float');
u_opt_out = strcat('u_opt:',num2str(design.N*design.m_inputs),':float');


% copy files from src folder to Protoip project 
copyfile('src/user_fgm_mpc.cpp','protoip_project/ip_design/src/');
copyfile('src/user_fgm_mpc.h','protoip_project/ip_design/src/');
copyfile('src/user_qp_matrices.h','protoip_project/ip_design/src/');


% perform HLS, i.e VHDL code generation from C
cd protoip_project
ip_design_build('project_name','my_project0', 'input', x_hat_in, 'output', u_opt_out);
cd ..
