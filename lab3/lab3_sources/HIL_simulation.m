% hardware-in-the-loop verificatio script


cd protoip_project

% load the bitstream to FPGA
ip_prototype_load('project_name','my_project0','board_name','zedboard','type_eth','udp');

% run HIL test
ip_prototype_test('project_name','my_project0','board_name','zedboard','num_test',design.N_sim);

cd ..


% read simulation data
x_store = importdata('protoip_project/ip_prototype/test/results/my_project0/x_hat_in_log.dat');
u_store = importdata('protoip_project/ip_prototype/test/results/my_project0/fpga_u_opt_out_log.dat');
u_store = u_store(:,1:design.m_inputs);


% plot results
subplot(2,1,1);
plot(x_store);
title('states (hardware simulation)');
subplot(2,1,2);
plot(u_store);
title('inputs (hardware simulation)');