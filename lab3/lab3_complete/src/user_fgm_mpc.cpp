#include "user_fgm_mpc.h"
#include "user_qp_matrices.h"
#include "math.h"

void fgm_mpc(float x_hat[n_states], float u_opt[n_opt_var])
{
	 int i,j,k;


	float Z_new[n_opt_var],Z[n_opt_var];
	float Y_new[n_opt_var], Y[n_opt_var];
	float h[n_opt_var];
	float T[n_opt_var];


	reset_grad: for(i = 0; i < n_opt_var; i++) 
	{
		#pragma HLS PIPELINE
		h[i] = 0;
	}
	grad: for(j = 0; j < n_states; j++)
	{
		grad_1: for(i = 0; i < n_opt_var; i++) 
		{
			#pragma HLS LOOP_FLATTEN
			#pragma HLS PIPELINE
			h[i] += x_hat[j] * h_x[j][i];
		}
	}

	guess_initialization: for(i = 0; i < n_opt_var; i++)
	{
		#pragma HLS PIPELINE
		Z[i] = 0;
		Y[i] = 0;
	}

	iteration_loop: for(k = 0; k < n_iter; k++)
	{
		reset_output:for(i = 0; i < n_opt_var; i++)
		{
			#pragma HLS PIPELINE
			T[i] = 0;
		}

		mv_mult:for(j = 0; j < n_opt_var; j++)
		{
			vv_mult: for(i = 0; i < n_opt_var; i++)
			{
				#pragma HLS LOOP_FLATTEN
				#pragma HLS PIPELINE
				T[i] += H_diff[i][j] * Y[j];
			}
		}

		subtract_gradient:for(i = 0; i < n_opt_var; i++)
		{
			#pragma HLS PIPELINE
			T[i] = T[i] - h[i];
		}

		projection_loop: for(i = 0; i < n_opt_var; i++)
		{
			#pragma HLS PIPELINE
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
			#pragma HLS PIPELINE
			Y_new[i] = beta_plus * Z_new[i] - beta_var * Z[i];		
		}

		update_loop: for(i=0; i < n_opt_var; i++)
		{
			#pragma HLS PIPELINE
			//iter_error += fabs(Y[i] - Y_new[i]);
			Z[i] = Z_new[i];
			Y[i] = Y_new[i];
		}
	}

	output_loop: for(i=0; i < n_opt_var; i++)
	{
		#pragma HLS PIPELINE
		u_opt[i] = Y_new[i];
	}
}
