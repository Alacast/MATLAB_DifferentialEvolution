function O = ex1(OPmode,varargin)
switch OPmode
  case 'init'
    M = MODEL();
    
    M.data = normrnd(2,0.25,[100,1]);
    
    M.bayes.priors(1,:) = {'normal',0,1};
    M.bayes.priors(2,:) = {'unif',0,1};
    M.bayes.priors(3,:) = {'normal',{1},{2}};
    
    
    M.fcn(1) = {@ex1};
    
    M.settings.n.chains = 50;
    M.settings.n.steps = 250;
    M.settings.n.groups = 10;
    
    O = M;
  case 'fit'
    params = varargin{1};
    data = varargin{2};
    
    
    
    O = MODEL.calc_safeLL(normpdf(data,params(1),params(2))); 
end
end