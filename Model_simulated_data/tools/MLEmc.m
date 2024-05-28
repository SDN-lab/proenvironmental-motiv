function [fits] = MLEmc(allmodels, allmodel_IDs)
% Analyses visualise results
% trials
% INPUT:    - allmodels: struct with all model parameters in it
%           - modelID: string if you want to pick one specific model
%           - doanalyse: vector indicating which analyses to run
% OPTIONS:  - doanalyse:    1. Plot AIC/BIC/NNL for all models
% OUPUT:    - variable called output that contains the summed AIC, BIC and
%             negative log likelihood as well as the values for each individual subject

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1. Plot AIC/BIC/NNL for all models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

no_o_models=numel(allmodel_IDs);
   
for imodel=1:no_o_models
      
    modelID=allmodel_IDs{imodel};

    %pick model:
    
    mod=allmodels.ml.(modelID);
      
    % information you want to have:
    
    all_nnl=[];
    all_aic=[];
    all_bic=[];
    all_param=[];
    
    % loop over subjects
    for is=1:numel(mod)
        nr_trials = size((allmodels.beh{1,is}.choice),2) - sum(isnan(allmodels.beh{1,is}.choice));   %%%% determine number of trials
        all_param=[all_param; mod{is}.x];
        param_names= mod{1}.xnames;
        nr_free_p=length(mod{is}.x);
        all_nnl=[all_nnl; mod{is}.fval];
        [aic, bic]=aicbic(-mod{is}.fval, nr_free_p, nr_trials);
        all_aic=[all_aic; aic];
        all_bic=[all_bic; bic];     
    end
    
    
    fits.(modelID).aic = all_aic;      % all subjects indidiuval aic values
    fits.(modelID).bic = all_bic;      % all subjects indidiuval bic values
    fits.(modelID).nll = all_nnl;      % all subjects indidiuval nll values
    fits.(modelID).aicSum = sum(all_aic); % summed value
    fits.(modelID).bicSum = sum(all_bic);
    fits.(modelID).nllSum = sum(all_nnl);
    
    fits.all_aic_all(:,imodel)=all_aic;      % all subjects indidiuval aic values
    fits.all_bic_all(:,imodel)=all_bic;      % all subjects indidiuval bic values
    fits.all_nnl_all(:,imodel)=all_nnl;      % all subjects indidiuval nll values
    fits.sum_all_aic(:,imodel)=sum(all_aic); % summed value
    fits.sum_all_bic(:,imodel)=sum(all_bic);
    fits.sum_all_nnl(:,imodel)=sum(all_nnl);
 
end

end
