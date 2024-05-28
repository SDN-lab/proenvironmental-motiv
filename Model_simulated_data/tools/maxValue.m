function [value] = maxValue(rootfile, param, modelID)

% Get maximum values (parameter upper bounds) for parameters:
% k - effort discounting
% rew - reward sensitivity
% input "param" must match one of the above paramter names

% Jo Cutler March 2022

minEffort = min(rootfile.effort); % minimum effort level
maxEffort = max(rootfile.effort); % maximum effort level
minReward = min(rootfile.reward); % minimum reward level
maxReward = max(rootfile.reward); % maximum reward level

%     val = (rew.*(reward)) - (discount.*(effort.^2)); % parabolic
%     val = (rew.*(reward)) - (discount.*(effort)); % linear
%     val = (rew.*(reward)) ./ (1 + (discount.*(effort))); % hyperbolic
% OR - (reward^.pow)...

% maximum k calculated as the discount rate that means the
% maximum reward and minimum effort has a value of 'low'
low = 0;
maxKp = (maxReward - low) ./ (minEffort.^2); % parabolic
maxKl = (maxReward - low) ./ (minEffort); % linear
maxKh = ((maxReward * (1/low)) - 1) / minEffort; % hyperbolic
if maxKh == Inf
    maxKh = max(maxKp, maxKl);
end

% maximum rew calculated as the reward sensitivity rate that means the
% minimum reward and maximum effort has a value of 'high'
high = 1 + (1-low);
maxRp = (high + (maxEffort^2)) / minReward; % parabolic
maxRl = (high + (maxEffort)) / minReward; % linear
maxRh = (high + (high*maxEffort)) / minReward; % hyperbolic
% minimum rew calculated as the reward sensitivity rate that means the
% maximum reward and minimum effort has a value of 'low
minRp = (low + minEffort^2) / maxReward; % parabolic
minRl = (low + minEffort) / maxReward; % linear
minRh = (low + (low.*minEffort)) / maxReward; % hyperbolic

% maximum pow calculated as the reward power parameter that means the
% minimum reward and maximum effort has a value of 'high'
maxPp = log(high + (maxEffort.^2)) ./ log(minReward); % parabolic
maxPl = log(high + (maxEffort)) ./ log(minReward); % linear
maxPh = log(high + (high .* maxEffort)) ./ log(minReward); % hyperbolic
% minimum pow calculated as the reward power parameter that means the
% maximum reward and minimum effort has a value of 'low
minPp = log(low + (minEffort.^2)) ./ log(maxReward); % parabolic
minPl = log(low + (minEffort)) ./ log(maxReward); % linear
minPh = log(low + (low .* minEffort)) ./ log(maxReward); % hyperbolic
if minPh == -Inf
    minPh = min(minPp, minPl);
end

if contains(modelID, 'k') & contains(modelID, 'rew')
    % maximum rew calculated as the reward sensitivity rate that means the
    % minimum reward, maximum effort and maximum k (for the relevant
    % discount function) has a value of 'high'
    maxRp = (high + (maxKp*(maxEffort^2))) / minReward; % parabolic
    maxRl = (high + (maxKl*maxEffort)) / minReward; % linear
    maxRh = (high + (high*maxKh*maxEffort)) / minReward; % hyperbolic
    minRp = low / maxReward; % parabolic
    minRl = low / maxReward; % linear
    minRh = low / maxReward; % hyperbolic
elseif contains(modelID, 'k') & contains(modelID, 'pow')
    %     high + (maxKp.*(maxEffort.^2)) = minReward.^maxPp; % parabolic
    maxPp = log(high + (maxKp.*(maxEffort.^2))) ./ log(minReward); % parabolic
    %     high + (maxKl.*(maxEffort)) = minReward.^maxPl; % linear
    maxPl = log(high + (maxKl.*(maxEffort))) ./ log(minReward); % linear
    %     high + (high.*maxKh.*(maxEffort)) = minReward.^maxPh; % hyperbolic
    maxPh = log(high + (high.*maxKh.*(maxEffort))) ./ log(minReward); % hyperbolic
    % low always <=1 so will be <=0
    minPp = 0;% log(low) ./ log(minReward); % parabolic
    minPl = 0;% log(low) ./ log(minReward); % linear
    minPh = 0;% log(low) ./ log(minReward); % hyperbolic
end

Vbreaks = 70; % calculated from the softmax, the lowest value that means prob = NaN;
Vmax = Vbreaks * 2; % set too high to start while loop
Vlimit = Vbreaks * 0.9;
while Vmax > Vbreaks
    if contains(modelID, 'rew')
        if contains(modelID, 'k')
            maxVp = (maxRp.*(maxReward)) - (0.*(minEffort.^2)); % parabolic
            maxVl = (maxRl.*(maxReward)) - (0.*(minEffort)); % linear
            maxVh = (maxRh.*(maxReward)) ./ (1 + (0.*(minEffort))); % hyperbolic
            minVp = (minRp.*(minReward)) - (maxKp.*(maxEffort.^2)); % parabolic
            minVl = (minRl.*(minReward)) - (maxKp.*(maxEffort)); % linear
            minVh = (minRh.*(minReward)) ./ (1 + (maxKp.*(maxEffort))); % hyperbolic
        else
            maxVp = (maxRp.*(maxReward)) - (minEffort.^2); % parabolic
            maxVl = (maxRl.*(maxReward)) - (minEffort); % linear
            maxVh = (maxRh.*(maxReward)) ./ (1 + (minEffort)); % hyperbolic
            minVp = (minRp.*(minReward)) - (maxEffort.^2); % parabolic
            minVl = (minRl.*(minReward)) - (maxEffort); % linear
            minVh = (minRh.*(minReward)) ./ (1 + (maxEffort)); % hyperbolic
        end
    elseif contains(modelID, 'pow')
        if contains(modelID, 'k')
            maxVp = (maxReward.^maxPp) - (0.*(minEffort.^2)); % parabolic
            maxVl = (maxReward.^maxPl) - (0.*(minEffort)); % linear
            maxVh = (maxReward.^maxPh) ./ (1 + (0.*(minEffort))); % hyperbolic
            minVp = (minReward.^minPp) - (maxKp.*(maxEffort.^2)); % parabolic
            minVl = (minReward.^minPl) - (maxKl.*(maxEffort)); % linear
            minVh = (minReward.^minPh) ./ (1 + (maxKh.*(maxEffort))); % hyperbolic
        else
            maxVp = (maxReward.^maxPp) - (minEffort.^2); % parabolic
            maxVl = (maxReward.^maxPl) - (minEffort); % linear
            maxVh = (maxReward.^maxPh) ./ (1 + (minEffort)); % hyperbolic
            minVp = (minReward.^minPp) - (maxEffort.^2); % parabolic
            minVl = (minReward.^minPl) - (maxEffort); % linear
            minVh = (minReward.^minPh) ./ (1 + (maxEffort)); % hyperbolic
        end
    else
        maxVp = (maxReward) - (0.*(minEffort.^2)); % parabolic
        maxVl = (maxReward) - (0.*(minEffort)); % linear
        maxVh = (maxReward) ./ (1 + (0.*(minEffort))); % hyperbolic
        minVp = (minReward) - (maxKp.*(maxEffort.^2)); % parabolic
        minVl = (minReward) - (maxKl.*(maxEffort)); % linear
        minVh = (minReward) ./ (1 + (maxKh.*(maxEffort))); % hyperbolic
    end
    
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
        if contains(modelID, 'rew')
            if contains(modelID, 'k')
                maxRp = Vlimit ./ maxReward; % parabolic
                maxRl = Vlimit ./ maxReward; % linear
                maxRh = Vlimit ./ maxReward; % hyperbolic
                %         minVp = (minRp.*(minReward)) - (maxKp.*(maxEffort.^2)); % parabolic
                %         minVl = (minRl.*(minReward)) - (maxKp.*(maxEffort)); % linear
                %         minVh = (minRh.*(minReward)) ./ (1 + (maxKp.*(maxEffort))); % hyperbolic
            else
                maxRp = Vlimit + (minEffort.^2) ./ maxReward; % parabolic
                maxRl = Vlimit + (minEffort) ./ maxReward; % linear
                maxRh = Vlimit + (Vlimit .* minEffort) ./ maxReward; % hyperbolic
                %         minVp = (minRp.*(minReward)) - (maxEffort.^2); % parabolic
                %         minVl = (minRl.*(minReward)) - (maxEffort); % linear
                %         minVh = (minRh.*(minReward)) ./ (1 + (maxEffort)); % hyperbolic
            end
        elseif contains(modelID, 'pow')
            if contains(modelID, 'k')
                maxPp = log(Vlimit) ./ log(maxReward); % parabolic
                maxPl = log(Vlimit) ./ log(maxReward); % linear
                maxPh = log(Vlimit) ./ log(maxReward); % hyperbolic
                %         minVp = (minReward.^minPp) - (maxKp.*(maxEffort.^2)); % parabolic
                %         minVl = (minReward.^minPl) - (maxKl.*(maxEffort)); % linear
                %         minVh = (minReward.^minPh) ./ (1 + (maxKh.*(maxEffort))); % hyperbolic
            else
                maxPp = log(Vlimit + (minEffort.^2)) ./ log(maxReward); % parabolic
                maxPl = log(Vlimit + (minEffort)) ./ log(maxReward); % linear
                maxPh = log(Vlimit + (Vlimit .* minEffort)) ./ log(maxReward); % hyperbolic
                %         minVp = (minReward.^minPp) - (maxEffort.^2); % parabolic
                %         minVl = (minReward.^minPl) - (maxEffort); % linear
                %         minVh = (minReward.^minPh) ./ (1 + (maxEffort)); % hyperbolic
            end
        else
            error(['Max value over ', num2str(Vlimit), ' for model without rew or pow parameters'])
        end
    else
    end
end

if contains(modelID, 'all')
    maxK = round(max([maxKl, maxKh, maxKp]), 2);
elseif contains(modelID, 'linear')
    maxK = round(maxKl,2);
    maxrew = round(maxRl,2);
    minrew = round(minRl,2);
    maxpow = round(maxPl,2);
    minpow = round(minPl,2);
elseif contains(modelID, 'hyperbolic')
    maxK = round(maxKh,2);
    maxrew = round(maxRh,2);
    minrew = round(minRh,2);
    maxpow = round(maxPh,2);
    minpow = round(minPh,2);
else
    maxK = round(maxKp,2);
    maxrew = round(maxRp,2);
    minrew = round(minRp,2);
    maxpow = round(maxPp,2);
    minpow = round(minPp,2);
end

switch param
    case 'k'
        value = maxK;
    case 'maxrew'
        value = maxrew;
    case 'minrew'
        value = minrew;
    case 'maxpow'
        value = maxpow;
    case 'minpow'
        value = minpow;
end

end

