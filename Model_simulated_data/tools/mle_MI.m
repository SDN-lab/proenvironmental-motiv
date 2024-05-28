function [s, fits, fitMeasures] = mle_MI(s, modelsTR, beston, bounds, nrep)
% Fits PM models with mle and does model comparison on simulated data for model
% identifiability
% Patricia Lockwood & Marco Wittmann, 2019
% Applied to model identifiability by Jo Cutler August 2020
%

s.PM.ml = {};

% define data set(s) of interest:
expids = {'PM'};

% how to fit RL:
M.dofit     = 1;                                                                                                     % whether to fit or not
M.doMC      = 1;                                                                                                     % whether to do model comparison or not
M.modid     = strrep(modelsTR, 'model_', 'ms_');

fitMeasures = {'aic','bic','nll','pseudoR2','choiceProbMedianR2'};

bestcol = contains(fitMeasures, beston);

%== I) RUN MODELS: ==========================================================================================

for iexp = 1:numel(expids)
    if M.dofit == 0,  break; end
    cur_exp = expids{iexp};
    
    %%% MLE fit %%%
    for im = 1:numel(M.modid) % for the number of models
        modelID=M.modid{im};
        for i=1:nrep
            s.(cur_exp).ml.(modelID) = fit_PM_model(s, modelID, bounds, i);
        end
    end
end

%== II) COMPARE MODELS: ==========================================================================================

for iexp = 1:numel(expids)
    if M.doMC~=1, break; end
    cur_exp = expids{iexp};
    s.(cur_exp).ml.fit = MLEmc(s.(cur_exp),M.modid);
end

% Calculate R^2 & extract model fit measures

for iexp = 1:numel(expids)
    cur_exp = expids{iexp};
    for im = 1:numel(M.modid) % for the number of models
        modelID = M.modid{im};
        s.(cur_exp).ml.fit.(modelID).pseudoR2 = pseudoR2(s.(cur_exp),modelID,2,0);
        s.(cur_exp) = choiceProbR2(s.(cur_exp),modelID,0);
    end
    [fits,~] = getfitsml(s.(cur_exp),fitMeasures,M.modid);
    fits(:,length(fitMeasures)+1) = 0;
    switch beston
        case {'aic','bic','nll'}
            [~, wins] = min(fits(:,bestcol));
        case {'pseudoR2','choiceProbMedianR2'}
            [~, wins] = max(fits(:,bestcol));
        otherwise
            error(['Call to mle_MI must specify one of the following to determine winning model: ',...
                fitMeasures{1},' / ',...
                fitMeasures{2},' / ',...
                fitMeasures{3},' / ',...
                fitMeasures{4},' / ',...
                fitMeasures{5}])
    end
    
    fits(wins,length(fitMeasures)+1) = 1;
    
    bicp = zeros(length(M.modid),1);
    for b = 1:length(s.PM.ml.fit.all_bic_all)
        [~, ind] = min(s.PM.ml.fit.all_bic_all(b,:));
        bicp(ind,1) = bicp(ind) + 1;
    end
    
    bicp = bicp / length(s.PM.ml.fit.all_bic_all) * 100;
    fits = [fits, bicp];
 
end

fitMeasures = [fitMeasures, 'wins', 'bicp'];

end