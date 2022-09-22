function par_recovery_wrap_cluster(i_job)
    addpath(genpath(pwd))    

    par_original = [[-2:0.5:1]; [-2:0.5:1]];
    modelidx = 2;

    par_o = par_original(:,i_job)';
    [par_r(i_job,:), par_r_allruns(i_job,:,:), Mu_rec(i_job,:)] = par_recovery(par_o, modelidx);


    %% Plot fake data vs. recovered data

    save(['par_rec_' num2str(i_job) '.mat'], 'par_r', 'par_r_allruns', 'Mu_rec', 'par_original')
end
% figd
% scatter(par_original, par_r);
% hold on
% plot([-2 2],[-2 2])
% xlabel('original mu')
% ylabel('recovered mu')
% axis square
% axis equal


% Plot the mu predictions against fake data mu pred
% Plot a grid search grid for the two variables