function NLL = get_NLL_muonly(X, StartingPoint, mu_resp, params, nSamples, model)

prob_mu = nan(1,length(X));
prob_conf = nan(1,length(X));

for i_trial = 1:length(X)
    S = X{i_trial};
    startingpoint = StartingPoint(i_trial);

    [Mu_hat] = model.f_simulate(params, S, startingpoint, nSamples);

%% Fit one Gaussian
    try
        %halfconfs = [0:1:50];
        %[~,idx_conf] = min(abs(halfconfs-conf_resp(i_trial)));
        
        std_likelihood = max(std(Mu_hat), 0.1);
        prob_mu(i_trial) = normpdf(mu_resp(i_trial), mean(Mu_hat), std_likelihood);
        %prob_conf(i_trial) = conf_dist(idx_conf);
        
        if isnan(prob_mu(i_trial))
            keyboard
        end
    catch
        keyboard
    end
end

%% Return the NLL for all trials

prob_mu(prob_mu<exp(-300)) = exp(-300);
%prob_conf(prob_conf<exp(-300)) = exp(-300);

NLL = sum(-log(prob_mu)); %+ sum(-log(prob_conf));

if NLL == inf || isnan(NLL)
    keyboard
end