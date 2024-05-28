function [ param_out ] = positive2norm(param, bound)
% transformation from values
% between 0 and an upper bound to gaussian space

% if no upper value specified cannot transform
if nargin == 1
    error('Must specify upper bound for parameter')
end

if length(bound) == 1
%     param_out = -log(1 ./ (param ./ bound) - 1); % below is identical but
%     easier to read
    param_out = (-log(bound./param - 1));
    %     param_out = exp(param / bound); % previous log version?
    
elseif length(bound) == 2
    
%     param_out = -log(1 ./ ((param - bound(1)) ./ (bound(2) - bound(1))) - 1); % below is identical but
%     easier to read
    param_out = (-log((bound(2) - bound(1)) ./ (param - bound(1)) - 1));
    
end

end

