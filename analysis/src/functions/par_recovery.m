function [par_r, par_r_allruns, Mu_rec] = par_recovery(par_o, modelidx)

%% Set parameters
%load(['Model' num2str(modelidx) '.mat'])

model = B_specifymodel(modelidx);

i_sub = 1;
numblock = 1; % 0 (space) or 1 (num)

i_block = numblock + 1; % 1 (space) or 2 (num)

[stim, ~] = readdata(i_sub,numblock);

%% Simulate mu and conf pdfs based on iterative function
nMeasurements = 1;
for i_trial = 1:length(stim.X)
    S = stim.X{i_trial};
    startingpoint = stim.StartingPoint(i_trial);
    
    Mu_fake(i_trial) = model.f_simulate(par_o, S, startingpoint, nMeasurements);
end

%% Try to fit parameters
%% Define model 
model = B_specifymodel(modelidx);

% Initial starting parmeters
par0 = rand(size(model.lb)).*(model.pub-model.plb) + model.plb;

nSamples = 100;
nRuns = 5;

for i_run = 1:nRuns
    [par_r_allruns, NLL_allruns] = bads(@(par) model.f_NLL(stim.X, stim.StartingPoint, Mu_fake', par, nSamples, model), par0, model.lb, model.ub, model.plb, model.pub);
end
%[pars_run, NLL_run] = bads(@(par) model.f_NLL(stim.X, stim.StartingPoint, Mu_est', Conf_est, par, nSamples, model), par0, model.lb, model.ub, model.plb, model.pub);

[bestNLL, bestrunidx] = min(NLL_allruns);
par_r = squeeze(par_r_allruns(bestrunidx,:));


%% Simulate mu and conf pdfs based on iterative function
nMeasurements = 100;
for i_trial = 1:length(stim.X)
    S = stim.X{i_trial};
    startingpoint = stim.StartingPoint(i_trial);
    
    mu_rec = model.f_simulate(par_r, S, startingpoint, nMeasurements);
        
    Mu_rec(i_trial) = mean(mu_rec);
end


end
