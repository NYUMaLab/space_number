%% C_modelpredictions

function Model = C_modelpredictions(modelname, muonly) % Append model predictions 
load(modelname);

blockvec = [0 1];
subvec = [1:10];

model = B_specifymodel(Model.modelidx);

if ~exist('muonly','var')
    muonly = 0;
else
    muonly = 1;
end

%% Read subject data

for i_block = blockvec+1
    num_block = blockvec(i_block);
   for i_sub = subvec
       [stim, resp] = readdata(i_sub,num_block);
       par = Model.bestpars(i_block,i_sub,:);
       nMeasurements = 100;
       for i_trial = 1:length(stim.X)
            S = stim.X{i_trial};
            startingpoint = stim.StartingPoint(i_trial);
            
            if muonly
                mu = model.f_simulate(par, S, startingpoint, nMeasurements);
                Model.modelpred_mu(i_block,i_sub,i_trial,:) = [mean(mu), std(mu)];
            else
                [mu,conf] = model.f_simulate(par, S, startingpoint, nMeasurements);
                Model.modelpred_mu(i_block,i_sub,i_trial,:) = [mean(mu), std(mu)];
                Model.modelpred_conf(i_block,i_sub,i_trial,:) = conf;
            end
            %Model.modelpred = [i_block, i_sub, i_trial, mean(mu), mean(conf)];
       end
   end
end

save(['Model' num2str(Model.modelidx) '_pred.mat'], 'Model');