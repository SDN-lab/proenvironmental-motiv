function [params] = getparams(rootfile, modelID, bounds, IDs, groups, countries)
% Function to extract the final parameters
%   Written by Jo Cutler August 2020

% INPUT:       - rootfile: file with one or models and resulting parameters
%              - modelID: name of the model to take parameters from
%              (winning model)
%              - IDs: cell array listing participant codes or numbers 
% OUTPUT:      - params: structure containing the parameters plus a table format 
%              of all this data to save
%
% DEPENDENCIES: - none

params.ID = IDs;
allnamesfinal = {'ui'};

if ~isempty(groups)
params.groups = groups;
allnamesfinal = [allnamesfinal 'intervention'];
else
params.groups = [];
end

if ~isempty(countries)
params.countries = countries;
allnamesfinal = [allnamesfinal 'country'];
else
params.countries = [];
end

names = getparnames(modelID); % returns a cell array of the parameter names
bounds = get_bounds(rootfile, modelID, bounds);

kind = [];
betaind = [];
climatekind = []; % index of climate k to calculate climate - food if relevant
foodkind = []; % index of food k to calculate climate - food if relevant
% find the index of k parameters and beta parameters
for ip = 1:length(names)
    thisp=names{ip};
    if contains(thisp, 'k') == 1
        kind = [kind, ip];
        if contains(thisp, 'food') == 1
            foodkind = length(kind);
        elseif contains(thisp, 'climate') == 1
            climatekind = length(kind);
        end
    elseif contains(thisp, 'beta') == 1
        betaind = [betaind, ip];
    end
end

if isempty(kind)
    bounds.k = [NaN, NaN];
end

params.ks_norm = rootfile.em.(modelID).q(:,kind); % extract ks from parameters
params.ks_final = norm2positive(params.ks_norm, bounds.k); % transform ks
params.betas_norm = rootfile.em.(modelID).q(:,betaind);  % extract betas from parameters
params.betas_final = norm2positive(params.betas_norm, bounds.beta); % transform betas

% put the parameters together with ks now first then betas
params.all_final = [params.ks_final, params.betas_final]; 
allind = [kind, betaind];

for ip = allind
    paramname = names{ip};
    % parameter names are in format k_agent but analysis needs format
    % agent_k
    if contains(paramname, 'k_') == 1
        paramname = strrep(paramname, 'k_', '');
        paramname = [paramname, '_k'];
    else
    end
    % paramname = ['PM_', paramname]; % add PL to names to avoid confusion with other tasks
    allnamesfinal = [allnamesfinal, paramname];
end

% if a k for food and for climate have been separately estimated include
% their subtraction in the final table
if isempty(foodkind) || isempty(climatekind)
else
    allnamesfinal = [allnamesfinal, 'climate-food_k'];
end

% for each participant extract their average % choices and reaction times
% in each condition
for i = 1:length(IDs)
   sum_data{i,1} = IDs{i};
   agents = unique(rootfile.beh{1, i}.agent); % the number of agents in the task, not the model
   for ag = 1:length(agents)
       a = agents(ag);
   ind = find(rootfile.beh{1, i}.agent == a);
   params.choice(i,a) = length(find(rootfile.beh{1, i}.choice(ind) == 1)) / length(find(rootfile.beh{1, i}.choice(ind) == 1 | rootfile.beh{1, i}.choice(ind) == 0));
%    params.RT(i,a) = mean(rootfile.beh{1, i}.RT(ind(rootfile.beh{1, i}.choice(ind) == 1 | rootfile.beh{1, i}.choice(ind) == 0)));
   end
end

agentnames = {'food', 'climate'}; 
% this assumes that if there are 2 agents, they are (in order) food & climate

% generate an array of column names for the % correct and RT columns (one
% for each agent in the task, not the model)
choiceRTnames = {};
choiceRT = {'_choice'};
for n = 1
for ag = 1:length(agents)
   choiceRTnames = [choiceRTnames, [agentnames{ag}, choiceRT{n}]];
end
end

% put all of the task (% correct & RT) model (ks & betas) parameters
% together in a cell array and table format with column headings
params.all_cell = [params.ID, ... 
    num2cell(params.groups), ... %     num2cell(params.RT), ...
    params.countries, ...
    num2cell(params.ks_final), ...
    num2cell(params.betas_final), ...
    num2cell(params.ks_final(:,climatekind) - params.ks_final(:,foodkind)),...
    num2cell(params.choice)];
params.all_table = cell2table(params.all_cell, 'VariableNames', ...
    [allnamesfinal, choiceRTnames]);

end

