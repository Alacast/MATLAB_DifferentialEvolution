function O = ex1(varargin)

if nargin == 0
  OPmode = 'init';
else
  OPmode = varargin{1};
end

switch OPmode
  case 'init'
    M = MODEL(mfilename);
    
    M.data = normrnd(2,0.25,[100,1]);
    
    M.bayes.priors(1,:) = {'normal',0,10};
    M.bayes.priors(2,1:3) = {'normal',0,10};
    
    O = M;
  case 'fit'
    params = varargin{2};
    data = varargin{3};
    
    
    params(2) = logistic(params(2));
    O = MODEL.calc_safeLL(normpdf(data,params(1),params(2))); 
    
  case 'pred'
    O = nan;
end
end