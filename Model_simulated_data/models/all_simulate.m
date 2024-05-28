
function [f, allout] = all_simulate(effort, reward, agent, p, model, kbounds, betabounds)% same as in models above in same order

params = get_params(['ms_', model]);

% for ip = 1:length(params)
%     thisp=params{ip};
%     if contains(thisp, 'k') == 1
%         pmin = min(kbounds);
%         pmax = max(kbounds);
%     elseif contains(thisp, 'beta') == 1
%         pmin = beta2norm(min(betabounds));
%         pmax = beta2norm(max(betabounds));
%     end
%     if (p(ip) < pmin || p(ip) > pmax), f=10000000; return; end
% end

%%%%% 1. Assign free parameters and other stuff:

if contains(model, 'one_k')
    discount = p(1);
    beta1 = 2;
elseif contains(model, 'two_k')
    discount = (agent==1).*p(1) + (agent==2).*p(2);% agent ==1 & win ==1
    beta1 = 3;
else
    error(['Cant`t determine number of k parameters from model name: ', model])
end

if contains(model, 'one_beta')
%     beta = norm2beta(p(beta1));
    beta = p(beta1);
elseif contains(model, 'two_beta')
%     beta = (agent==1).*norm2beta(p(beta1)) + (agent==2).*norm2beta(p(beta1+1));
    beta = (agent==1).*p(beta1) + (agent==2).*p(beta1+1);
else
    error(['Cant`t determine number of beta parameters from model name: ', model])
end

base = 1;

%%%% Model - devalue reward by effort.

if contains(model, 'linear')
    val = reward - (discount.*(effort));
elseif contains(model, 'hyperbolic')
    val = reward ./ (1 + (discount.*(effort)));
else
    if contains(model, 'beta_')
        error(['Detection of model as linear / hyperbolic / neither may not be correct for model ', model])
    else
        val = reward - (discount.*(effort.^2));
    end
end

prob =  exp(val.*beta)./(exp(base*beta) + exp(beta.*val));

for t = 1:length(prob)
    chosen(t,1) = double(rand < (prob(t)));
end

prob(~chosen) =  1 - prob(~chosen);
[r, c] = size(prob);
if r>c
prob = prob(:,1);
else
prob = prob(1,:);
end

if max(size(prob)) == 1
    error('Variable prob should have as many rows as trials - check above')
end

% calculate neg-log-likelihood
f=-nansum(log(prob));

allout.all_V= val;
allout.prob = prob;
allout.data = chosen;
allout.choice = chosen;
allout.agent = agent;
allout.effort = effort;
allout.reward = reward;

end
