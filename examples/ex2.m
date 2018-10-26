function O = ex2(OPmode,varargin)


if nargin == 0
  OPmode = 'init';
else
  OPmode = varargin{1};
end


switch OPmode
  case 'init'
    M = MODEL();
    
    % % % data % % %
    % construct data from 2 groups, with individual variation
    G = [1 1 1 1 1, 2 2 2 2 2];
    
    gMeans = [-5,5];
    sMeans = [-2:2,-2:2];
    
    dataMeans = gMeans(G) + sMeans;
    dataSD = 1;
    
    nObs = 1000;
    
    data = nan(nObs,10);
    for ss = 1:10
      data(:,ss) = normrnd(dataMeans(ss),dataSD,[nObs,1]);
    end
    M.data = data(:);
    
    % groups
    M.bayes.priors(1,:) = {'normal',0,10,[],[]};
    M.bayes.priors(2,:) = {'normal',0,10,[],[]};
    % subject dev
    for ss = 1:5
      M.bayes.priors(2+ss,[1,4,3]) = {'normal',1,1};
    end
    for ss = 6:10
      M.bayes.priors(2+ss,[1,4,3]) = {'normal',2,1};
    end
    
    
    M.fcn(1) = {@ex2};
    
    M.settings.n.chains = 1;
    M.settings.n.steps = 10000;
    M.settings.n.groups = 1;
    
    O = M;
  case 'fit'
    params = varargin{1};
    data = varargin{2};
    nObs = 1000;
    
    
    sParams = params(3:end);        
    sInd = sort(repmat([1:10]',nObs,1));
    
    betas = [sParams(sInd)]';
    
    O = MODEL.calc_safeLL(normpdf(data,betas,1));
end
end