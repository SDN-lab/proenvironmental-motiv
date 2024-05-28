function [value] = maxValue(rootfile, param, modelID)

% Get maximum values (parameter upper bounds) for parameters:
% k - effort discounting
% input "param" must match one of the above paramter names

% Jo Cutler March 2022

minEffort = min(rootfile.beh{1, 1}.effort); % minimum effort level
maxEffort = max(rootfile.beh{1, 1}.effort); % maximum effort level
minReward = min(rootfile.beh{1, 1}.reward); % minimum reward level
maxReward = max(rootfile.beh{1, 1}.reward); % maximum reward level

% maximum k calculated as the discount rate that means the
% maximum reward and minimum effort has a value of 'low'
low = 0;
maxKp = (maxReward - low) ./ (minEffort.^2); % parabolic
maxKl = (maxReward - low) ./ (minEffort); % linear
maxKh = ((maxReward * (1/low)) - 1) / minEffort; % hyperbolic
if maxKh == Inf
    maxKh = max(maxKp, maxKl);
end

Vbreaks = 70; % calculated from the softmax, the lowest value that means prob = NaN;
Vmax = Vbreaks * 2; % set too high to start while loop
Vlimit = Vbreaks * 0.9;
while Vmax > Vbreaks
    
        maxVp = (maxReward) - (0.*(minEffort.^2)); % parabolic
        maxVl = (maxReward) - (0.*(minEffort)); % linear
        maxVh = (maxReward) ./ (1 + (0.*(minEffort))); % hyperbolic
        minVp = (minReward) - (maxKp.*(maxEffort.^2)); % parabolic
        minVl = (minReward) - (maxKl.*(maxEffort)); % linear
        minVh = (minReward) ./ (1 + (maxKh.*(maxEffort))); % hyperbolic
    
    if contains(modelID, 'linear')
        Vmax = maxVl;
        Vmin = minVl;
    elseif contains(modelID, 'hyperbolic')
        Vmax = maxVh;
        Vmin = minVh;
    else
        Vmax = maxVp;
        Vmin = minVp;
    end
    
%     base = 1;
%     beta = 10;
%     prob = exp(Vmax.*beta) ./ (exp(base*beta) + exp(Vmax.*beta));
%     prob = exp(Vmin.*beta) ./ (exp(base*beta) + exp(Vmin.*beta));
    
    if Vmax > Vbreaks
            error(['Max value over ', num2str(Vlimit), ' for model without rew or pow parameters'])
    end
end

if contains(modelID, 'all')
    maxK = round(max([maxKl, maxKh, maxKp]), 2);
elseif contains(modelID, 'linear')
    maxK = round(maxKl,2);
elseif contains(modelID, 'hyperbolic')
    maxK = round(maxKh,2);
else
    maxK = round(maxKp,2);
end

switch param
    case 'k'
        value = maxK;
end

end

