function [params] = getparnames(modelID)
% Lookup table to get names of free parameters per model
% Jo Cutler 2020

%%%%%
if contains(modelID, 'one_k')
    params{1} = 'k';
elseif contains(modelID, 'two_k')
    params{1} = 'food_k';
    params{2} = 'climate_k';
elseif ~contains(modelID, 'k')
    params = {};
else
    error(['Cant`t determine number of k parameters from model name: ', model])
end

if contains(modelID, 'one_beta')
    params{end+1} = 'beta';
elseif contains(modelID, 'two_beta')
    params{end+1} = 'food_beta';
    params{end+1} = 'climate_beta';
else
    error(['Cant`t determine number of beta parameters from model name: ', model])
end

end

