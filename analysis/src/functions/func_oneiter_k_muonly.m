%% Func_iter_avg_gaussian_oneiter

% Gaussian noise with a set starting point and a single iteration
% FLEXIBLE noise that scales with distance
% Takes both stimulus and cursor starting position as the reference point
% Alpha (update) is simply 1. Just a one-step update from the starting
% point to the best estimate of the model.

function [Mu_hat] = func_oneiter_k_muonly(params, S, StartingPoint, nMeasurements)
% should give a vector nMeasurements long for mu_hat

k_sig_scale = exp(params(1));

N    = length(S);

mu_hat_0   = StartingPoint;
ref        = mu_hat_0; % initialize the reference point

S = repmat(S,nMeasurements,1);

% Generative model
d = ref - S; % d is how far off the cursor is (e.g. positive means cursor is RIGHT of the line)
%sig(find(N~=0),:) = k_sig_scale*abs(d(find(N~=0),:)); %sigma = scaling constant x absolute distance    
sig = k_sig_scale.*abs(d);

var = sig.^2;

X = S + randn(nMeasurements,N).* sqrt(var);

% Inference
%mu_hat = mean(S,2) + randn(nSamples,1).*1/N*sqrt(mean(sig.^2,2));

hypmu = [-200:1:300];
boxprior = hypmu>=0 & hypmu<=100;
likelihood = normpdf(hypmu,mean(X,2),(1./N).*sqrt(sum(var,2)));
post = likelihood.*boxprior;
post = post./sum(post,2);
Mu_hat = sum(post.*hypmu,2);

% Update
delta = (Mu_hat-ref); 
ref = ref + delta;                   % * no learning rate (learnrate = 1)  % Error signal (refminusmu_mean) should be multiplied by an error
                                       % rate before you adjust.
Mu_hat = ref; % Store last mu_hat

% %% confidence
% 
% halfconfs = [0:1:50];
% 
% leftconfs = Mu_hat - halfconfs;
% rightconfs = Mu_hat + halfconfs;
% 
% phit = nan(nMeasurements,length(halfconfs));
% for i_c = 1:length(halfconfs)
%     inrange = hypmu>leftconfs(:,i_c) & hypmu<rightconfs(:,i_c);
%     phit(:,i_c) = sum(post.*inrange,2);
% end
% 
% rewardfn = exp(-(halfconfs*2)*alpha); %alpha is mapping between objective and subjective reward
% 
% expected_utility = phit.*rewardfn;
% 
% p = exp(beta.*expected_utility); %beta is inverse temperature; higher = lower noise
% p = p./sum(p,2);
% 
% % Assume independence of the mu_hat and conf_hat
% 
% conf_dist = mean(p);

end
    