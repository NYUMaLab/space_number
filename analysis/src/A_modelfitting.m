%% General model fitting script for space-number
function A_modelfitting(i_job)

%% Specify subject, block, model
% num_block = 1;
% sub_id = 1;
% modelidx = 1;
% i_run = 1;

addpath(genpath(pwd))

modelvec = [2];
blockvec = [0 1];
subvec = [1:10];
runvec = [1:100];

designmat = combvec(modelvec,blockvec,subvec,runvec)';

modelidx   = designmat(i_job,1);
num_block   = designmat(i_job,2);
subidx     = designmat(i_job,3);
runidx     = designmat(i_job,4);

%% Read subject data
[stim, resp] = readdata(subidx,num_block);

%% Define model 
model = B_specifymodel(modelidx);

% Initial starting parameters
par0 = rand(size(model.lb)).*(model.pub-model.plb) + model.plb;

nSamples = 100;

[pars_run, NLL_run] = bads(@(par) model.f_NLL(stim.X, stim.StartingPoint, resp.mu_resp, resp.conf_resp, par, nSamples, model), par0, model.lb, model.ub, model.plb, model.pub);

%% save output
model.pars_run = pars_run;
model.NLL_run = NLL_run;

model.sub_id = subidx;
model.num_block = num_block;
model.modelidx = modelidx;
model.i_run = runidx;

if num_block
    block_text = '1';
else
    block_text = '0';
end

modelidx_text = sprintf('%02d', modelidx);
subidx_text = sprintf('%02d', subidx);
runidx_text = sprintf('%02d', runidx);

save(['modelfit_model' modelidx_text '_block' block_text '_sub' subidx_text '_run' runidx_text '.mat'], 'stim','resp','model');