function [fval,fit] = mod_ms_all(behavData, q, fitop, modelID, bounds, varargin)

% runs standard Prosocial motivation disocunt model
% P Lockwood modified 1 July 2019 from MK Wittmann, Oct 2018
%
% INPUT:    - behavData: behavioural input file
% OUTPUT:   - fval and fitted variables
%

%%
% -------------------------------------------------------------------------------------
% 1 ) Define free parameters
% -------------------------------------------------------------------------------------

if nargin > 5
    prior      = varargin{1};
end

params = get_params(['ms_', modelID]);

for p = 1:length(params)
    
    qt(p) = norm2positive(q(p), [bounds.lower(p), bounds.upper(p)]); % transform parameters from gaussian space to model space
    
end

all_prob = [];
all_V  = [];

%%% 0.) Load information for that subject:    % load in each subjects variables for the experiment
chosen   = behavData.choice';
effort   = behavData.effort';
reward   = behavData.reward';
agent    = behavData.agent';

indmiss2=chosen==2;
indmiss=isnan(chosen);
indmiss = (indmiss + indmiss2) > 0;
chosen(indmiss) = 0;%[];
% effort(indmiss) = [];
% reward(indmiss) = [];
% agent(indmiss)  = [];

% Define free parameters

if contains(modelID, 'one_k')
    discount = qt(1);
    beta1 = 2;
elseif contains(modelID, 'two_k')
    discount = (agent==1).*qt(1) + (agent==2).*qt(2);
    beta1 = 3;
elseif ~contains(modelID, 'k')
    discount = [];
    beta1 = 1;
else
    error(['Cant`t determine number of k parameters from model name: ', modelID])
end

if contains(modelID, 'one_beta')
    beta = qt(beta1);
elseif contains(modelID, 'two_beta')
    beta = (agent==1).*qt(beta1) + (agent==2).*qt(beta1+1);
else
    error(['Cant`t determine number of beta parameters from model name: ', modelID])
end

base = 1;
    
%%%% Model - devalue reward by effort

if contains(modelID, 'linear')
    val = reward - (discount.*(effort));
elseif contains(modelID, 'hyperbolic')
    val = reward ./ (1 + (discount.*(effort)));
else
    val = reward - (discount.*(effort.^2));
end

prob =  exp(val.*beta)./(exp(base*beta) + exp(beta.*val));

% prob =  exp(val./beta) ./ (exp(base./beta) + exp(val./beta)); % other direction for softmax

% alternative calculation of softmax - Todd Vogel
% valB = val.*beta;
% LSE = max(valB) + log(exp(base-max(valB)) + exp(valB - max(valB))); % LogSumExp % max value for each option or overall
% LL = valB - LSE; % Log-likelihood for choice==1 (equivalent to log(prob))
% LL(~chosen) =  base - LSE(~chosen); %for choice==0 (equivalent to log(1-prob)) (0 is used as the "alternative" option in the softmax function, which simplifies to the logistic function because there is only one option (binary outcome))
% softmax_out = exp(valB - LSE); % Output from the softmax, can be used later to simulate choices/data 
% prob = exp(valB - LSE); % Probability of choice==1

prob(~chosen) =  1 - prob(~chosen); % probability of choosing the chosen option

% different version of matlab have different defaults to a row or a column - use the one that selects all trials
if any(size(prob) == 1) && any(size(prob) == max(size(agent)))
    if size(prob,1) == max(size(agent))
        prob = prob(:,1);
    elseif size(prob,2) == max(size(agent))
        prob = prob(1,:);
    else
        error('Check dimensions of prob variable - should be 1*ntrials or ntrials*1');
    end
else
    error('Check dimensions of prob variable - should be 1*ntrials or ntrials*1');
end

%%% 4. now save stuff:
all_V      =  val;
all_prob   =  prob;

% all choice probablities
ChoiceProb=all_prob';
% ChoiceProb(ChoiceProb < 0.0001) = 0.0001; % very small probabilities can cause problems 

% -------------------------------------------------------------------------------------
% 4 ) Calculate model fit:
% -------------------------------------------------------------------------------------

nll =-nansum(log(ChoiceProb));                                                % the thing to minimize

% if nll == Inf
%     nll = realmax;
% else
% end

if fitop.doprior == 0                                                               % NLL fit
    fval = nll;
elseif fitop.doprior == 1                                                           % EM-fit:   P(Choices | h) * P(h | O) should be maximised, therefore same as minimizing it with negative sign
    fval = -(-nll + prior.logpdf(q));
end

% infinity values can cause problems
% if fval == Inf
%     fval = realmax;
% %     disp('Inf f');
% else
% end

% % make sure f is not just low because of Nans in prob-variable:

sumofnans=sum(sum(isnan(chosen)));
if sum(isnan(ChoiceProb))~=sumofnans
    disp('ERROR NaNs in choice and choice prob dont agree');
    keyboard;
    return;
end

% -------------------------------------------------------------------------------------
% 5) Calculate additional Parameters and save:
% -------------------------------------------------------------------------------------

if fitop.dofit ==1
    
    fit         = struct;
    fit.xnames  = params;
    
    fit.choiceprob = [ChoiceProb];
    fit.mat    = [all_V];
    fit.names  = {'V'};
    
end

end
