function model = B_specifymodel(modelidx)

% Model 1: One iteration,  with k_sig_scale and b_sig_scale
         % starting point is cursor spawn location

switch modelidx
    case {1}
        f_NLL = @get_NLL;
        f_simulate = @func_iter_avg_gaussian_oneiter_bk;
        pars = {'(1) k_sig_scale: sigma distance-scaling factor',...
                '(2) b_sig: sigma baseline',...
                '(3) alpha: mapping between objective and subjective reward',...
                '(4) beta: inverse temperature for confidence resp, higher = lower noise'};
        npars = length(pars);
        lb = [log(0),... %k_sig_scale
              log(0),... %b_sig
              log(0),... %alpha
              log(0)];%,... %beta
        ub = [inf,... %k_sig_scale
              inf,... %b_sig
              inf,... %alpha
              inf];%,... %beta
        plb = [log(0.01),... %k_sig_scale
              log(0.01),... %b_sig
              log(0.01),... %alpha
              log(1)];%,... %beta
        pub = [log(1),... %k_sig_scale
              log(1),... %b_sig
              log(0.1),... %alpha
              log(20)];%,... %beta 
    case {2}
        f_NLL = @get_NLL_muonly;
        f_simulate = @func_oneiter_bk_muonly;
        pars = {'(1) k_sig_scale: sigma distance-scaling factor',...
                '(2) b_sig: sigma baseline'};
        npars = length(pars);
        lb = [log(0),... %k_sig_scale
              log(0)];    %b_sig
        ub = [inf,... %k_sig_scale
              inf];   %b_sig
        plb = [log(0.01),... %k_sig_scale
              log(0.01)];  %b_sig
        pub = [log(1),... %k_sig_scale
              log(1)]; %b_sig     
  case {3}
        f_NLL = @get_NLL_muonly;
        f_simulate = @func_oneiter_b_muonly;
        pars = {'(1) b_sig: sigma baseline'};
        npars = length(pars);
        lb = [log(0)];   %b_sig
        ub = [inf];   %b_sig
        plb = [log(0.01)];  %b_sig
        pub = [log(1)]; %b_sig        
   case {4}
        f_NLL = @get_NLL_muonly;
        f_simulate = @func_oneiter_k_muonly;
        pars = {'(1) k_sig: sigma baseline'};
        npars = length(pars);
        lb = [log(0)];   %k_sig_scale
        ub = [inf];   %k_sig_scale
        plb = [log(0.01)];  %k_sig_scale
        pub = [log(1)]; %k_sig_scale
    
   case {5}
        f_NLL = @get_NLL;
        f_simulate = @func_iter_avg_gaussian_oneiter_constnoise;
        pars = {'(1) sig: fixed sigma',...
                '(2) alpha: mapping between objective and subjective reward',...
                '(3) beta: inverse temperature for confidence resp, higher = lower noise'};
        npars = length(pars);
        lb = [log(0),... %sig
              log(0),... %alpha
              log(0)];%,... %beta
        ub = [inf,... %sig
              inf,... %alpha
              inf];%,... %beta
        plb = [log(0.01),... %sig
              log(0.01),... %alpha
              log(1)];%,... %beta
        pub = [log(2),... %sig
              log(0.1),... %alpha
              log(20)];%,... %beta  
end

model.npars           = npars;
model.lb              = lb;
model.ub              = ub;
model.plb             = plb;
model.pub             = pub;

model.f_NLL           = f_NLL;
model.f_simulate      = f_simulate;