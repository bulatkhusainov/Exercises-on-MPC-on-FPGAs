#include "user_fgm_mpc.h"
#include "user_qp_matrices.h"
#include "math.h"
//#include "mex.h"

void fgm_mpc(float x_hat[n_states], float u_opt[n_opt_var])
{
	 int i,j,k;


	float Z_new[n_opt_var],Z[n_opt_var];
	float Y_new[n_opt_var], Y[n_opt_var];
	float h[n_opt_var];
	float T[n_opt_var];

	float iter_error;

	reset_grad: for(i = 0; i < n_opt_var; i++) 
	{
		h[i] = 0;
	}
	grad: for(j = 0; j < n_states; j++)
	{
		grad_1: for(i = 0; i < n_opt_var; i++) 
		{
			h[i] += x_hat[j] * h_x[j][i];
		}
	}

	guess_initialization: for(i = 0; i < n_opt_var; i++)
	{
		Z[i] = 0;
		Y[i] = 0;
	}

	iteration_loop: for(k = 0; k < n_iter; k++)
	{
		mv_mult:for(i = 0; i < n_opt_var; i++)
		{
			T[i] = 0;
			vv_mult: for(j = 0; j < n_opt_var; j++)
			{
				T[i] += H_diff[i][j] * Y[j];
			}
			T[i] = T[i] - h[i];
		}

		projection_loop: for(i = 0; i < n_opt_var; i++)
		{
			if(T[i] > u_max[i])
			{
				Z_new[i] = u_max[i];
			}
			else if (T[i] < u_min[i])
			{
				Z_new[i] = u_min[i];
			}
			else
			{
				Z_new[i] = T[i];
			}
		}

		fgm_step:for(i = 0; i < n_opt_var; i++)
		{
			Y_new[i] = beta_plus * Z_new[i] - beta_var * Z[i];		
		}

		//iter_error = 0;
		update_loop: for(i=0; i < n_opt_var; i++)
		{
			//iter_error += fabs(Y[i] - Y_new[i]);
			Z[i] = Z_new[i];
			Y[i] = Y_new[i];
		}
		//printf("error[%d] = %f \n",k,iter_error);
	}

	output_loop: for(i=0; i < n_opt_var; i++)
	{
		u_opt[i] = Y_new[i];
	}
}
