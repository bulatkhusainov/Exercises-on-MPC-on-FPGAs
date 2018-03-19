function [qp_problem] = qp_generator(design, model_d)
% this function generates QP matrices based on design parameters and plant
% model

    %% design parameters
    A = model_d.a;       % state space matrices
    B = model_d.b;
    N = design.N;        % horizon length 
    n = design.n_states; %number of states
    m = design.m_inputs; %number of inputs
   
    
    
    %% define upper and lower bounds on inputs
    u_min = -0.1; % we assume the same upper/lower bounds on all inputs
    u_max =  0.1;
    qp_problem.u_max = kron(ones(1,N),u_max*ones(1, m));
    qp_problem.u_min = kron(ones(1,N),u_min*ones(1, m));     

  
    
    %% calculating prediction matrices
    A_big = zeros(0);
    for i=0:N
        A_big = [A_big; A^i];
    end

    B_inter = zeros(size(B));
    for i=0:N-1
        B_inter = [B_inter; (A^i)*B];
    end

    B_big = [];
    for i=0:(N-1)
        shifted = circshift(B_inter,[i*n,0]);
        shifted(1:i*n, :) = zeros(i*n, m);
        B_big = [B_big shifted];
    end


    %% calculating penalty matrices
    Q = eye(n);
    Q_term = Q;
    qp_problem.Q = Q;
    qp_problem.Q_term = Q;
    Q_big = kron(eye(N), Q);
    Q_big = blkdiag(Q_big, Q_term);
    qp_problem.Q_big = Q_big;

    R = 0.01*eye(m);
    qp_problem.R = R;
    R_big = kron(eye(N), R);
    qp_problem.R_big = R_big;

    %% calculate hessian and gradient matrices for condensed QP
    qp_problem.H = B_big'*Q_big*B_big + R_big;
    qp_problem.h_x = A_big'*Q_big*B_big; %h = X'*h_x;
    
    % floating point arithmetic
    mu = abs(min(eig(qp_problem.H))); % min eigenvalue
    if(mu <= 0)
        error('The problem is not convex! Change weight matrices')
    end
    L  = abs(max(eig(qp_problem.H))); % max eigenvalue
    a = 1/L; % scaling factor

    % scale Hessian and gradient matrices
    qp_problem.h_x = a*qp_problem.h_x;
    qp_problem.H_diff = eye(size(qp_problem.H)) - a*qp_problem.H;

    % extra momentum step size
    qp_problem.beta_var = (sqrt(L) - sqrt(mu))/(sqrt(L) + sqrt(mu));
    qp_problem.beta_plus = 1 + qp_problem.beta_var;

    
    
end

