%%  parameter header file
fileID = fopen('src/user_fgm_mpc.h','w');

fprintf(fileID,'#ifndef USER_FGM_MPC \n');
fprintf(fileID,'#define USER_FGM_MPC \n\n');

fprintf(fileID,'#define n_iter    %d\n', design.n_iter);
fprintf(fileID,'#define n_states  %d\n', size(model_d.a,1));
fprintf(fileID,'#define m_inputs  %d\n', size(model_d.b,2));
fprintf(fileID,'#define n_opt_var %d\n\n', design.N*size(model_d.b,2));

fprintf(fileID,'void fgm_mpc(float x_hat[n_states], float u_opt[n_opt_var]);\n\n');

fprintf(fileID,'#endif \n');

fclose(fileID);

%% precalculated matrices header file
fileID = fopen('src/user_qp_matrices.h','w');

fprintf(fileID,'#ifndef USER_QP_MATRICES \n');
fprintf(fileID,'#define USER_QP_MATRICES \n\n');

fprintf(fileID,'\t //data arrays\n');
H_diff = qp_problem.H_diff; fprintf(fileID,strcat('\t',variables_declaration('2d',H_diff), '\n'));
h_x = qp_problem.h_x; fprintf(fileID,strcat('\t',variables_declaration('2d',h_x), '\n'));
u_max = qp_problem.u_max; fprintf(fileID,strcat('\t',variables_declaration('1d',u_max), '\n'));
u_min = qp_problem.u_min; fprintf(fileID,strcat('\t',variables_declaration('1d',u_min), '\n'));
beta_var = qp_problem.beta_var; fprintf(fileID,strcat('\t',variables_declaration('var',beta_var),'\n'));
beta_plus = qp_problem.beta_plus; fprintf(fileID,strcat('\t',variables_declaration('var',beta_plus),'\n\n'));

fprintf(fileID,'#endif \n');

fclose(fileID);