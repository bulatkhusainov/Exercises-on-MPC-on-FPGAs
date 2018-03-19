%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% icl::protoip
% Author: asuardi <https://github.com/asuardi>
% Date: November - 2014
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function test_HIL(project_name)


addpath('../../.metadata');
mex FPGAclientMATLAB.c
load_configuration_parameters(project_name)

rng('shuffle');

% load problem data
load ../../../prob_data

x_hat_in=rand(1,design.n_states);

for i=1:NUM_TEST
	tmp_disp_str=strcat('Test number ',num2str(i));
	disp(tmp_disp_str)


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% generate random stimulus vector x_hat_in. (-5<=x_hat_in <=5)
	%x_hat_in=rand(1,X_HAT_IN_LENGTH)*10-5;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save x_hat_in_log
	if (TYPE_TEST==0)
		filename = strcat('../../ip_prototype/test/results/', project_name ,'/x_hat_in_log.dat');
	else
		filename = strcat('../test/results/', project_name ,'/x_hat_in_log.dat');
	end
	fid = fopen(filename, 'a+');
   
	for j=1:length(x_hat_in)
		fprintf(fid, '%2.18f,',x_hat_in(j));
	end
	fprintf(fid, '\n');

	fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Start Matlab timer
	tic

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% send the stimulus to the FPGA simulation model when IP design test or to FPGA evaluation borad when IP prototype, execute the algorithm and read back the results
	% reset IP
	Packet_type=1; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=1;
	data_to_send=1;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


	% send data to FPGA
	% send x_hat_in
	Packet_type=3; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=1;
	data_to_send=x_hat_in;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


	% start FPGA
	Packet_type=2; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=1;
	data_to_send=0;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


	% read data from FPGA
	% read fpga_u_opt_out
	Packet_type=4; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=U_OPT_OUT_LENGTH;
	data_to_send=0;
	[output_FPGA, time_IP] = FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);
	fpga_u_opt_out=output_FPGA;
	% Stop Matlab timer
	time_matlab=toc;
	time_communication=time_matlab-time_IP;
    
    % simulate plant
    x_hat_in = (model_d.a*x_hat_in' + model_d.b*fpga_u_opt_out(1:design.m_inputs))';


	%save fpga_u_opt_out_log.dat
	if (TYPE_TEST==0)
		filename = strcat('../../ip_prototype/test/results/', project_name ,'/fpga_u_opt_out_log.dat');
	else
		filename = strcat('../test/results/', project_name ,'/fpga_u_opt_out_log.dat');
	end
	fid = fopen(filename, 'a+');
   
	for j=1:length(fpga_u_opt_out)
		fprintf(fid, '%2.18f,',fpga_u_opt_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);



	%save fpga_time_log.dat
	if (TYPE_TEST==0)
		filename = strcat('../../ip_prototype/test/results/', project_name ,'/fpga_time_log.dat');
	else
		filename = strcat('../test/results/', project_name ,'/fpga_time_log.dat');
	end
	fid = fopen(filename, 'a+');
   
	fprintf(fid, '%2.18f, %2.18f \n',time_IP, time_communication);

	fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% compute with Matlab and save in a file simulation results
	[matlab_u_opt_out] = foo_user(project_name,x_hat_in);


	%save matlab_u_opt_out_log
	if (TYPE_TEST==0)
		filename = strcat('../../ip_prototype/test/results/', project_name ,'/matlab_u_opt_out_log.dat');
	else
		filename = strcat('../test/results/', project_name ,'/matlab_u_opt_out_log.dat');
	end
	fid = fopen(filename, 'a+');
   
	for j=1:length(matlab_u_opt_out)
		fprintf(fid, '%2.18f,',matlab_u_opt_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%write a dummy file to tell tcl script to continue with the execution

filename = strcat('_locked');
fid = fopen(filename, 'w');
fprintf(fid, 'locked write\n');
fclose(fid);

if strcmp(TYPE_DESIGN_FLOW,'vivado')
	quit;
end

end
