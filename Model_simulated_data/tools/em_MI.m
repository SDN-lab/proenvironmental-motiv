function [s, fits, fitMeasures] = em_MI(s, modelsTR, beston, bounds)
% Fits PM models with em and does model comparison on simulated data for model
% identifiability
% Patricia Lockwood & Marco Wittmann, 2019
% Applied to model identifiability by Jo Cutler August 2020
%

s.PM.em = {};

% define data set(s) of interest:
expids = {'PM'};

% how to fit RL:
M.dofit     = 1;                                                                                                     % whether to fit or not
M.doMC      = 1;                                                                                                     % whether to do model comparison or not
M.modid     = strrep(modelsTR, 'model_', 'ms_');

fitMeasures = {'lme','bicint','xp','pseudoR2','choiceProbMedianR2'};

bestcol = contains(fitMeasures, beston);

%== I) RUN MODELS: ==========================================================================================

for iexp = 1:numel(expids)
   if M.dofit == 0,  break; end
   cur_exp = expids{iexp};   

   %%% EM fit %%%
   for im = 1:numel(M.modid) % for the number of models
      dotry=1;
      while 1==dotry
%         try
%           close all;
            s.(cur_exp).em = EMfit_ms(s.(cur_exp),M.modid{im}, bounds);dotry=0; 
%         catch
%            dotry=1; disp('caught');
%         end
      end
   end

   %%% calc BICint for EM fit
   for im = 1:numel(M.modid)
       
      s.(cur_exp).em.(M.modid{im}).fit.bicint =  cal_BICint_ms(s.(cur_exp), M.modid{im}, bounds);     
      
   end   
end

%== II) COMPARE MODELS: ==========================================================================================

for iexp = 1:numel(expids)
   if M.doMC~=1, break; end
   cur_exp = expids{iexp};
   s.(cur_exp) = EMmc_ms(s.(cur_exp),M.modid);                              
end

 %%% calculate R^2 & extract model fit measures 

for iexp = 1:numel(expids)
    cur_exp = expids{iexp};
    for im = 1:numel(M.modid) % for the number of models
        s.(cur_exp).em.(M.modid{im}).fit.pseudoR2 = pseudoR2(s.(cur_exp),M.modid{im},2,1);
        s.(cur_exp) = choiceProbR2(s.(cur_exp),M.modid{im},1);
    end
    [fits,fitstab] = getfits(s.(cur_exp),fitMeasures,M.modid);
end

for iexp = 1:numel(expids)
    cur_exp = expids{iexp};
    for im = 1:numel(M.modid) % for the number of models
        s.(cur_exp).em.(M.modid{im}).fit.pseudoR2 = pseudoR2(s.(cur_exp),M.modid{im},2,1);
        s.(cur_exp) = choiceProbR2(s.(cur_exp),M.modid{im},1);
    end
    [fits,~] = getfits(s.(cur_exp),fitMeasures,M.modid);
    fits(:,length(fitMeasures)+1) = 0;
    switch beston
        case {'lme','bicint'}
            [~, wins] = min(fits(:,bestcol));
        case {'xp','pseudoR2','choiceProbMedianR2'}
            [~, wins] = max(fits(:,bestcol));
        otherwise
            error(['Call to em_MI must specify one of the following to determine winning model: ',...
                fitMeasures{1},' / ',...
                fitMeasures{2},' / ',...
                fitMeasures{3},' / ',...
                fitMeasures{4},' / ',...
                fitMeasures{5}])
    end
    fits(wins,length(fitMeasures)+1) = 1;
    
end

fitMeasures = [fitMeasures, 'wins'];


end

