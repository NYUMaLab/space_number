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

function [mu_hat_binned, iter_] = func_iter_avg_lognormal_single_binned(params, T)
% should give a vector nMeasurements long for both mu_hat and conf_hat

blockidx = params(end);
subjidx = params(end-1);

load('spliced_trials_q10.mat'); % LOAD TRIALS AND QUANTILE BINS PER SUBJECT X BLOCK TYPE X N

iter_ = nan(length(T),1);
mu_hat_binned = nan(length(T),1);

for i = 1:length(T)
    i_trial = T(i);
    
    X = X_{subjidx, blockidx, i_trial};
    N_stim    = length(X);
    bin_edges = squeeze(qdata(subjidx, blockidx, N_stim-1, :));
    
    alpha = exp(params(1));
    sig = exp(params(2));
    convergence_threshold = exp(params(3));
    lapse = exp(params(4));
    
    range = 100;
    ns = 1e3; % Samples for a single measurement



    mu_hat_0   = rand * range;
    ref        = mu_hat_0; % initialize the reference point

    iter = 1;
    stepsize = inf;
    while (stepsize > convergence_threshold)

        % Generative model
        d = ref - X; % d is how far off the cursor is (e.g. positive means cursor is RIGHT of the line)
        logx = log(abs(d)) + sig * randn(1,N_stim); % x is vector of measurement of absolute distances to all the lines
                                               % Constant noise on the log of the distance log normal distributions:
                                               % if you add negative noise, you still end up with a positive x because it's
                                               % exponentiated again

         % Inference through sampling
        logabsd_s = bsxfun(@plus, logx, sig * randn(ns,N_stim)); % For each line (N lines), draw ns samples
                                                            % Add the sample to the log x (fixed observations)

                                                            % adding noise in log space

                                                            % One column of
                                                            % logabsd_s
                                                            % (histogram) looks
                                                            % like a normal
                                                            % distribution; exp
                                                            % --> lognormal
        d_s = bsxfun(@times, sign(d), exp(logabsd_s)); % Exponentiate to put in actual d space-- add back in the signs

        refminusmu_s   = mean(d_s,2); % Take mean across lines; vector of ns by 1 -- strive for refminusmu_s to be zero
        %figure
        %hist(refminusmu_s); % Should look like a normal distribution
        
        extreme_refminusmu_s = mean(refminusmu_s);

        mu_s = ref - refminusmu_s; % Absolute coordinates: posterior samples of mu
        %%% Impose post-hoc interval prior: i.e., discard out-of-band mu samples %%%
        intervalprior = 0<=mu_s & 100>=mu_s; % Find in-bound samples

        mu_s = mu_s(intervalprior);
        refminusmu_s = refminusmu_s(intervalprior); % Keep only those in-bound samples

        refminusmu_mean = mean(refminusmu_s); % Get the mean of the samples to get the posterior mean (over the cursor position relative to true mean)
                                              % If the cursor is to the
                                              % RIGHT of hypothesized mean,
                                              % refminusmu_mean is positive.
                                              
        % Display a warning when all of the samples are out of bound...
         % FOR ALL SAMPLES OUT OF BOUND, SET TO THE EXTREME (0 or 100)
        if length(refminusmu_s) == 0
            warning(['All samples were out of bounds for params = ' num2str(params) ' extreme_refminusmu_s = ' num2str(extreme_refminusmu_s)])
            if extreme_refminusmu_s > 100
                refminusmu_mean = 100;
            elseif extreme_refminusmu_s < 0
                refminusmu_mean = 0;
            else
                warning(['nonsense error'])
            end       
        end

        % Update
        mu_hat = ref - alpha * refminusmu_mean; 
                           % * alpha   % Error signal (refminusmu_mean) should be multiplied by an error
                                               % rate before you adjust.

        stepsize = abs(ref-mu_hat); % Update absolute stepsize % ALTERNATIVE: stopping condition is fitted "tolerance" for difference in left vs. right side (average distance on left, average distance on right, weighted by number of lines on either side)

        ref = mu_hat; % Make the new reference point the posterior mean

        iter = iter + 1;
    end
    
    if rand<lapse
        mu_hat_binned(i) = randi(length(bin_edges)-1,1);
    else
        mu_hat_binned(i) = discretize(mu_hat,bin_edges);
    end
    iter_(i) = iter;
end
        
end
    