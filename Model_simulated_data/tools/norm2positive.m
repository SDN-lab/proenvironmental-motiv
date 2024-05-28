function [ param_out ] = norm2positive(param, bound)
% transformation from gaussian space to space 
% bounded between 0 and value given as bound
% e.g. if bound is 5, between 0 and 5

% if no upper value specified use 10

if nargin == 1
    bound = 10;
end

if length(bound) == 1
%     param_out = logsig(param) * bound; % below is identical but doesn't
%     require logsig function from toolbox
    param_out = (1 ./ (1 + exp(-param))) * bound;
%     param_out = log(param) * bound; % previous log version? 
elseif length(bound) == 2
%     param_out = (logsig(param) * (bound(2) - bound(1))) + bound(1); % below is identical but doesn't
%     require logsig function from toolbox
    param_out = ((1 ./ (1 + exp(-param))) * (bound(2) - bound(1))) + bound(1);
%     param_out = (log(param) * (bound(2) - bound(1))) + bound(1); % previous log version? 
end

end

