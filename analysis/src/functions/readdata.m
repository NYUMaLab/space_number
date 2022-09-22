function [stim, resp] = readdata(sub_id, num_block)

allcsvdata = readtable('allcsvdata.csv');
i_sub = allcsvdata{:,13}==sub_id & allcsvdata{:,2}==num_block;

mu_resp = allcsvdata{i_sub, 5}; 
conf_resp = allcsvdata{i_sub, 6}; 

allXvec = readtable('allXvec.csv');
i_cut = 2:height(allXvec);
X = cellfun(@str2num, allXvec{i_cut,2}, 'UniformOutput', false); 
X = X(i_sub);

StartingPoint_ = readtable('StartingPoint.csv');
i_cut = 2:height(allXvec);
StartingPoint = StartingPoint_{i_cut,2};
StartingPoint = StartingPoint(i_sub);

stim.maxrange = cellfun(@max, X)-cellfun(@min, X);
stim.std = cellfun(@std, X);
stim.mean = cellfun(@mean, X);

stim.X = X;
stim.StartingPoint = StartingPoint;

stim.num_block = num_block;
stim.sub_id = sub_id;

resp.mu_resp = mu_resp;
resp.conf_resp = conf_resp;

end