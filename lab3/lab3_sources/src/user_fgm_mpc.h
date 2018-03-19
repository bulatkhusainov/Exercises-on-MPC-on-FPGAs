#ifndef USER_FGM_MPC 
#define USER_FGM_MPC 

#define n_iter    100
#define n_states  20
#define m_inputs  10
#define n_opt_var 100

void fgm_mpc(float x_hat[n_states], float u_opt[n_opt_var]);

#endif 
