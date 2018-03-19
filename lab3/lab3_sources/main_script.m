%% define parameters of the design
% design.Ts = 0.1;            % MPC sampling time
% design.N = 10;              % horizon length
% design.n_iter = 100;        % number of iterations of FGM algorithm

%% generate mass spring damper system state-space model
%[model_d, model_c, design]= model_generator(design);

%% formulate a condensed QP
%qp_problem = qp_generator(design, model_d);
%save prob_data model_d model_c design qp_problem % save problem data

%% generate the header with precalculated matrices
%generate_header;

%% software-in-the-loop simulation
%SIL_simulation;

%% Perform high-level synthesis, i.e synthesize VHDL code from C
%hls;

%% Perform synthesis, i.e. convert VHDL code into FPGA bitstream
%synthesis;

%% hardtware-in-the-loop simulation
%HIL_simulation;
