function O = newModel(varargin)

if nargin == 0
  OPmode = 'init';
else
  OPmode = varargin{1};
end

switch OPmode
  case 'init'
    M = MODEL(mfilename);
    
    M.data = [];
    
    M.bayes.priors(1,:) = {[],[],[],    [],[],    [],[]};
    
    M.settings.n.chains = 1;
    M.settings.n.steps = 10000;
    M.settings.n.groups = 1;
    
    O = M;
  case 'fit'
    params = varargin{2};
    data = varargin{3};
    
    O = [];
    
    
  case 'pred'
    O = nan;
end
end