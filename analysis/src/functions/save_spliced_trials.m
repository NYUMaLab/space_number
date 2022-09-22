%% save spliced trials
% saves trials spliced by subject x block type 
% saves quantile bins (10% percentiles) 
% spliced by subject x block type x number
clear
clc

allcsvdata = readtable('allcsvdata.csv');
allXvec = readtable('allXvec.csv');
allX_ = allXvec{:,2};
allX = cellfun(@str2num,allX_,'UniformOutput',false);

blocktypes = [0 1];
Ns = [2:6];
quantiles = [0:10:100];

for subidx = [1:10]
    for blockidx = [1:2] %BLOCKIDX -- 1 = space, 2 = number
        i_subblock = allcsvdata.Sub_ID== subidx & allcsvdata.Num_block==blocktypes(blockidx); % Get indices for trials for subject 1, num_block ==1
        muresp = allcsvdata.Resp_loc(i_subblock); % Get mu_est for subject 1, num_block ==1
        confresp = allcsvdata.Resp_conf(i_subblock); % Get conf_est for subject 1
        
        X_(subidx, blockidx,:) = allX(i_subblock);
        muresp_(subidx, blockidx, :) = muresp;
        
        for i_N = 1:length(Ns)
            N = Ns(i_N);
            i_subblocknum = i_subblock & allcsvdata.N == N;
            
            resp_subblockN = allcsvdata.Resp_loc(i_subblocknum);
            qdata(subidx, blockidx, i_N, :) = prctile(resp_subblockN,quantiles);        
            
        end
    end
end

save('spliced_trials_q10.mat', 'X_', 'qdata', 'muresp_')



