function [f] = all_real(p, chosen, effort, reward, agent, modelID, outtype)% same as in models above in same order

params = get_params(['ms_', modelID]);

%%%%% 1. Assign free parameters and other stuff:

if contains(modelID, 'one_k')
    discount = p(1);
    beta1 = 2;
elseif contains(modelID, 'two_k')
    discount = (agent==1).*p(1) + (agent==2).*p(2);
    beta1 = 3;
else
    error(['Cant`t determine number of k parameters from model name: ', modelID])
end

if contains(modelID, 'one_beta')
    beta = p(beta1);
elseif contains(modelID, 'two_beta')
    beta = (agent==1).*p(beta1) + (agent==2).*p(beta1+1);
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
    if contains(modelID, 'beta_')
        error(['Detection of model as linear / hyperbolic / neither may not be correct for model ', modelID])
    else
        val = reward - (discount.*(effort.^2));
    end
end

prob =  exp(val.*beta)./(exp(base*beta) + exp(beta.*val));
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

if outtype==2
    allout.all_V= val;
    allout.prob = prob;
    f=allout;

end
