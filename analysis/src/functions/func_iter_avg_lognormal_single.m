%% func_iter_avg
% INPUT: X, alpha, sig, maxiter
% OUTPUT: mu_hat, mu_hat_all, niter

% adapted from weiji's "distance_model.m"

% Plot summary statistics after manually inputting parameters

% Get a mu_hat distribution for a single trial
% Fit a mixture of Gaussians to the distribution -- with 3 components --
% get standard mixture Gaussian (EM etc.) don't write own code for that
% This keeps your mu_hat continuous. 
% A few hundred mu_hats; -- pick probability at that distribution of the
% subject's response

% For every trial, subject, parameter, have to create a large fitted
% distribution

function [mu_hat, conf_hat, iter, pathlength] = func_iter_avg_lognormal_single(params, X)
% Gives a single mu_hat and conf_hat prediction


alpha = exp(params(1));
sig = exp(params(2));
convergence_threshold = exp(params(3));
rewardfactor = params(4);

range = 100;
ns = 1e3; % Samples for a single measurement

N_stim    = length(X);

mu_hat_0   = rand * range;
ref        = mu_hat_0; % initialize the reference point

iter = 1;
stepsize = inf;
pathlength = 0;
while (stepsize > convergence_threshold)

    % Keep drawing until ns valid samples
    s_N = nan(N_stim, ns);

    for i_N = 1:N_stim
        
        % Generative model
        d = ref - X(i_N); % d is how far off the cursor is (e.g. positive means cursor is RIGHT of the line)
        logx = log(abs(d)) + sig * randn; % x is vector of measurement of absolute distances to all the lines
                                               % Constant noise on the log of the distance log normal distributions:
                                               % if you add negative noise, you still end up with a positive x because it's
                                               % exponentiated again
       s_ = [];
        while ~(length(s_) == ns)
            
            ns_batch = ns - length(s_);
            
             % Inference through sampling
            logabsd_s = bsxfun(@plus, logx, sig * randn(ns_batch,1)); % Draw ns_batch remaining samples
                                                                % Add the sample to the log x (fixed observations)

                                                                % adding noise in log space

                                                                % One column of
                                                                % logabsd_s
                                                                % (histogram) looks
                                                                % like a normal
                                                                % distribution; exp
                                                                % --> lognormal
            d_s = bsxfun(@times, sign(d), exp(logabsd_s)); % Exponentiate to put in actual d space-- add back in the signs

            s = ref - d_s;
            intervalprior = 0<=s & 100 >=s;

            s_ = [s_; s(intervalprior)];
        end
        
        s_N(i_N,:) = s_;
    end
        mu_s   = mean(s_N); % Take mean across lines; vector of ns by 1 -- strive for refminusmu_s to be
                                          % Get the mean of the samples to get the posterior mean (over the cursor position relative to true mean)
                                          % If the cursor is to the
                                          % RIGHT of hypothesized mean,
                                          % refminusmu_mean is positive.
        
        %figure
        %hist(refminusmu_s); % Should look like a normal distribution

%         mu_s = ref - refminusmu_s; % Absolute coordinates: posterior samples of mu
        %%% Impose post-hoc interval prior: i.e., discard out-of-band mu samples %%%
        

    % Update
    updatesize = ref-mean(mu_s);
        
    mu_hat = ref - alpha * updatesize; 
                       % * alpha   % Error signal (refminusmu_mean) should be multiplied by an error
                                           % rate before you adjust.
                                           
    stepsize = abs(ref-mu_hat); % Update absolute stepsize

    ref = mu_hat; % Make the new reference point the posterior mean

    iter = iter + 1;
    pathlength = pathlength + abs(updatesize); % Calculate total path length
end

%%%% CONFIDENCE? %%%%

max_halfconf = min([mu_hat, 100-mu_hat]);
halfconfs = [0:0.2:max_halfconf];
leftconfs = mu_hat - halfconfs;
rightconfs = mu_hat + halfconfs;

AUC = nan(1,length(halfconfs));
for i_c = 1:length(halfconfs)
    AUC(i_c) = sum(mu_s>leftconfs(i_c) & mu_s<rightconfs(i_c))./length(mu_s);
end

rewardfn = exp(-(halfconfs*2)/rewardfactor);  

expected_utility = AUC.*rewardfn;

[~,i_conf_hat] = max(expected_utility);
conf_hat = halfconfs(i_conf_hat);

end  
        
    