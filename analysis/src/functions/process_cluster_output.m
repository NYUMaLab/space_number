function Model = process_cluster_output(modelidx)
   
   
    blockvec = [0 1];
    subvec = [1:10];
    runvec = [1:100];
    
  model = B_specifymodel(modelidx);
    
  cd('/Users/jennlauralee/GitHub Repos/space-number/MODELLING/Iterative distance model/')
  cd(['model' num2str(modelidx)])

  Model.bestNLL = nan(length(blockvec), length(subvec));
  Model.maxNLLdiff = nan(length(blockvec), length(subvec));
  Model.bestpars = nan(length(blockvec), length(subvec), model.npars);
  Model.NLL = nan(length(blockvec),length(subvec),length(runvec));
  
   for i_block = blockvec
       iblockidx = i_block+1;
       for i_sub = subvec
           for i_run = runvec
               try
                load(['modelfit_model' sprintf('%02d', modelidx) '_block' num2str(i_block) '_sub' sprintf('%02d', i_sub) '_run' sprintf('%02d', i_run)]);
                Model.pars(iblockidx,i_sub,i_run,:) = model.pars_run;
                Model.NLL(iblockidx,i_sub,i_run) = model.NLL_run;
               catch
                   
               end
           end

           [Model.bestNLL(iblockidx,i_sub), bestrunidx] = min(Model.NLL(iblockidx,i_sub,:));
           Model.maxNLLdiff(iblockidx,i_sub) = max(Model.NLL(iblockidx,i_sub,:)) - min(Model.NLL(iblockidx,i_sub,:));
           Model.bestpars(iblockidx,i_sub,:) = Model.pars(iblockidx,i_sub,bestrunidx,:);
       end
   end
   
   Model.modelidx = modelidx;
   
save(['Model' num2str(modelidx) '.mat'], 'Model');
end

%incomplete_run_idx = find(isnan(Model1.NLL));