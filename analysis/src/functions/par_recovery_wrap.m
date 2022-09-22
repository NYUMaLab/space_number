close all
clear
clc

par_original = [[-4:1:3];[-4:1:3]];%[[-2:0.5:1]; [-2:0.5:1]]; %[-2:0.5:1];
modelidx = 2;

% Set parameters
model = B_specifymodel(modelidx);
i_sub = 1;
numblock = 1; % 0 (space) or 1 (num)
i_block = numblock + 1; % 1 (space) or 2 (num)
[stim, ~] = readdata(i_sub,numblock);

% Get Mu_original
for ii = 1:length(par_original)
    par_o = par_original(:,ii)';

    % Simulate mu and conf pdfs based on iterative function
    nMeasurements = 1;
    for i_trial = 1:length(stim.X)
        S = stim.X{i_trial};
        startingpoint = stim.StartingPoint(i_trial);

        Mu_o(ii,i_trial) = model.f_simulate(par_o, S, startingpoint, nMeasurements);
    end
end

%% Par recovery

for ii = 1:length(par_original)
    par_o = par_original(:,ii)';
    [par_r(ii,:), par_r_allruns(ii,:,:), Mu_rec(ii,:)] = par_recovery(par_o, modelidx);
end

%% Grid search alternative
nSamples = 100;

par_space = [-7:1:3];

for i_par = 6%:length(par_original)
    for ii = 1:length(par_space)
        for jj = 1:length(par_space)
            NLL(ii,jj) = model.f_NLL(stim.X, stim.StartingPoint, Mu_o(i_par,:), [par_space(ii) par_space(jj)], nSamples, model);
        end
    end
    
    figd
    imagesc(NLL)
    set(gca, 'XTick', [1:1:length(par_space)], 'XTickLabel', par_space)
    set(gca, 'YTick', [1:1:length(par_space)], 'YTickLabel', par_space)
    xlabel('k sig');
    ylabel('b sig');
end

%% Plot pars vs. recovered pars
figd
scatter(par_original(1,:), par_r(:,1));
hold on
plot([-2 2],[-2 2])
xlabel('original par')
ylabel('recovered par')
axis square
axis equal


figd
scatter(par_original(2,:), par_r(:,2));
hold on
plot([-2 2],[-2 2])
xlabel('original par')
ylabel('recovered par')
axis square
axis equal

%% Plot data vs. recovered data
figd

for ii = 1:length(par_original)
    subplot(4,2,ii)
    scatter(Mu_o(1,:), Mu_rec(1,:));
     hold on
     plot([0 100],[0 100])
    xlabel('original mu')
    ylabel('recovered mu')
    axis square
    axis equal
end

%%
save(['par_rec_model' num2str(modelidx) '.mat'], 'par_r', 'par_r_allruns', 'Mu_rec', 'par_original')
