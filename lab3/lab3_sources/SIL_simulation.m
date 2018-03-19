% software-in-the-loop verificatio script

% generate_code script must be run before running this script
tmp_str = 'mex src/mex_fgm_mpc.cpp src/user_fgm_mpc.cpp';
eval(tmp_str); % compile mex file


% closed loop test with a random initial condition
design.N_sim = 200; 
x = rand(design.n_states,1); % test with the first initial condition only
x_store = zeros(design.n_states ,design.N_sim);
u_store = zeros(design.m_inputs ,design.N_sim);
for i = 1:design.N_sim
    u_opt_trajectory = mex_fgm_mpc(x);
    u_opt = u_opt_trajectory(1:design.m_inputs);
    x_next = model_d.a*x + model_d.b*u_opt;
    
    x_store(:,i) = x;
    u_store(:,i) = u_opt; 
    x = x_next;
end


subplot(2,1,1);
plot(x_store');
title('states (software simulation)');
subplot(2,1,2);
plot(u_store');
title('inputs (software simulation)');