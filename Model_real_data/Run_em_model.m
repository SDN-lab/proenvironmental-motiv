%%%%%%%%%
%% Modelling for prosocial motivation task using expectation maximisation
%%%%%%%%%

% Fits models using expectation maximisation (em) approach and does model comparison
% Written by Patricia Lockwood, January 2020
% Based on code by MK Wittmann, October 2018
% Edited by Jo Cutler, August 2020

%%%%%%%%%
% Step 1 - get data in the format of a varible 's' that contains a struct for each persons data
% Step 2 - run this script to fit models  
% Dependencies: tools subfolder containing required functions e.g. fit_PM_model
%               models subfolder containing various comp models you have made 
% Step 3 - compare the AIC's and BIC's using the script visualize_model_PM
% (see below)

%% Input for script
%       - Participants data file format saved in 's':

%% Output from script
%   - workspaces/EM_fit_results_[date] has all variables from script
%           - 's.PM.em' contains model results including the model parameters per ppt
%   - datafiles in specified output directory:
%       - PM_model_fit_statistics.csv - model comparison fit statistics
%       - EM_fit_parameters.csv - estimated parameters for each participant
%       - Compare_fit_between_groups.csv - median R^2 for each participant with group index

%% Prosocial motivation models based Lockwood et al. (2017)
% test different variations of discount rate (k) and beta parameters:
%   - one_k_one_beta
%   - two_k_one_beta
%   - one_k_two_beta
%   - two_k_two_beta
% and shape of discounting:
%   - parabolic 
%   - linear
%   - hyperbolic

%%

%== -I) Prepare workspace: ============================================================================================

clearvars
addpath('models');
addpath('tools');
% addpath('spm12');
% setFigDefaults; % custom function - make sure it is in the folder

include = 'full'; % 'pilot' or 'full' (all countries) **

%== 0) Load and organise data: ==========================================================================================
% load data:
file_name = [include, '_data_for_model']; % specify data **
load([file_name]); % .mat file saved from the behavioural script that contains all participants data in 's'

e = 'PM';
s.(e).expname = 'ProsocialMotivation';
s.(e).em = {};

bounds.beta = [0, 10];
kdetails = 'var'; 

output_dir = '../PM_R_code/data/'; % enter path to save output in **

% how to fit RL:
M.dofit     = 1;                                                                            % whether to fit or not
M.doMC      = 1;                                                                            % whether to do model comparison or not
M.modid     = {'ms_two_k_one_beta', 'ms_two_k_one_beta_linear', 'ms_two_k_one_beta_hyperbolic',...
    'ms_two_k_two_beta', 'ms_two_k_two_beta_linear', 'ms_two_k_two_beta_hyperbolic'};%
   
fitMeasures = {'lme','bicint','xp','pseudoR2','choiceProbMedianR2'}; % which fit measures to calculate ** 
criteria = 'xp'; % of above, which to use to choose the best model **

% run optional additional analysis using the VBA toolbox? (see below)
doVBA = 0; % 1 = yes, 0 = no **
VBAon = 'group'; % or 'country

% define experiment of interest:
e = 'PM';% **

%== I) RUN MODELS: ==========================================================================================

if M.dofit
    %%% EM fit %%%
    for im = 1:numel(M.modid) % for the number of models, can also fit in parallel with parfor
        if ~isfield(s.(e).em,(M.modid{im}))
            rng default % resets the randomisation seed to ensure results are reproducible (MATLAB 2019b)
            dotry=1;
            while 1==dotry
                    close all;
                    allfits{im} = EMfit_ms_par(s.(e),M.modid{im},bounds);dotry=0;
%                     save(['workspaces/EM_fit_results_',include,'_',date,'.mat'])
            end
        end
    end
    
    for im = 1:numel(M.modid) % for the number of models
%         try
        s.(e).em.(M.modid{im}) = allfits{1,im}.(M.modid{im});
%         catch
%         end
    end
    
    save(['workspaces/EM_fit_results_',include,'_',date,'.mat'])  
    
%     M.modid = fieldnames(s.(e).em);
    
    %%% calc BICint for EM fit
    parfor im = 1:numel(M.modid)
        rng default % resets the randomisation seed to ensure results are reproducible (MATLAB 2019b)
        allbics{im} =  cal_BICint_ms(s.(e),M.modid{im},bounds);
    end
    
    for im = 1:numel(M.modid) % for the number of models
        s.(e).em.(M.modid{im}).fit.bicint = allbics{1,im};
    end
    
end

%== II) COMPARE MODELS: ==========================================================================================

if M.doMC
    rng default % resets the randomisation seed to ensure results are reproducible (MATLAB 2019b)
    s.(e) = EMmc_ms(s.(e),M.modid);
    
    % Calculate R^2 & extract model fit measures
    
    for im = 1:numel(M.modid) % for the number of models
        s.(e).em.(M.modid{im}).fit.pseudoR2 = pseudoR2(s.(e),M.modid{im},2,1);
        s.(e) = choiceProbR2(s.(e),M.modid{im},1);
    end
    [fits.(e),fitstab.(e)] = getfits(s.(e),fitMeasures,M.modid);
end

%== III) LOOK AT PARAMETERS: ==========================================================================================

switch criteria
    case {'xp', 'pseudoR2','choiceProbMedianR2'}
        bestmod = find(fitstab.(e).(criteria) == max(fitstab.(e).(criteria)));
    case {'lme', 'bicint'}
        bestmod = find(fitstab.(e).(criteria) == min(fitstab.(e).(criteria)));
end
bestname = M.modid{bestmod};
disp(['Extracting parameters from ', bestname,' based on best ',criteria])

for i=1:length(s.(e).ID)
    IDs(i, :)=s.(e).ID{1,i}.ID;
    try
        group(i, :)=s.(e).groups(i,1);
    catch
        group = [];
    end
    try
    country(i, :)=s.(e).countries(i,1);
    catch
        country = [];
    end
end

params = getparams(s.(e), bestname, bounds, IDs, group, country);

%== IV) SAVE: ==========================================================================================

writetable(params.all_table,[output_dir,'EM_fit_parameters_',include,'_',bestname,'.csv'],'WriteRowNames',true) % combine this with other participant data for analysis

save(['workspaces/EM_fit_results_',include,'_',date,'.mat'])  

fit = fits.(e);
fit = [[1:numel(M.modid)]',fit];
fit(:,end+1) = fit(:,find(contains(fitMeasures, 'bicint'))+1) - min(fit(:,find(contains(fitMeasures, 'bicint'))+1));
fittabnum = cell2table(num2cell(fit), 'VariableNames', ['model', fitMeasures, 'relbic']);
writetable(fittabnum,[output_dir,e,'_model_fit_statistics_',include,'.csv'],'WriteRowNames',true)
