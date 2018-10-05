function L = logistic(p,varargin)
% converts R to 0-1

% if additional arguments, change shape
if nargin>1
  steep = varargin{1};
else
  steep = 1;
end

fcn = @(p) 1 ./ (1+exp(-steep*p));

L = fcn(p);
end