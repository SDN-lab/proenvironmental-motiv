function [params] = get_params( modelID)
% Lookup table to get number of free parameters per model
% MKW 2018

if contains(modelID, 'one_k')
    kparams = {'k'};
elseif contains(modelID, 'two_k')
    kparams = {'k_self', 'k_other'};
elseif ~contains(modelID, 'k')
    kparams = {};
else
    error(['Cant`t determine number of k parameters from model name: ', modelID])
end
    
if contains(modelID, 'one_beta')
    betaparams = {'beta'};
elseif contains(modelID, 'two_beta')
    betaparams = {'beta_self', 'beta_other'};
else
    error(['Cant`t determine number of beta parameters from model name: ', modelID])
end
    
params = [kparams, betaparams];

end

