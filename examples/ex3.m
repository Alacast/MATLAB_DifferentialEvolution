function O = ex3(varargin)

if nargin == 0
  OPmode = 'init';
else
  OPmode = varargin{1};
end

%  hierarchical model when the distribution informing individual levels is
%  determined by a combination of hierarchical parameters
switch OPmode
  case 'init'
    M = MODEL();
    
    % % % data % % %
    % construct data from 2 groups, with individual variation
    deflections = [-5 5];
    nSubs = 3;
    sMeans = linspace(-1,1,nSubs);
    
    dMeans = deflections + sMeans';
    dMeans = dMeans(:)';
    dataSD = .1;
    
    nObs = 10;
    
    data = nan(nObs,2*nSubs);
    for ss = 1:2*nSubs
      data(:,ss) = normrnd(dMeans(ss),dataSD,[nObs,1]);
    end
    
    sInd = repmat(sort(repmat([1:(nSubs)]',nObs,1)),2,1);
    cInd = [ones(nSubs*nObs,1);2*ones(nSubs*nObs,1)];
    M.data = [data(:),sInd,cInd];
    
    % groups
    M.bayes.priors(1,:) = {'normal',0,10,[],[],[],[]};
    M.bayes.priors(2,1:3) = {'normal',0,5};
    M.bayes.priors(3,1:3) = {'normal',0,5};
    % subject dev
    for ss = 1:nSubs
      M.bayes.priors(3+ss,[1,4:7]) = {'normal',1,2,[],@(x) 5*logistic(x)};
    end
    
    M.fcn(1) = {@ex3};
    
    M.settings.n.chains = 10;
    M.settings.n.steps = 1000;
    M.settings.n.groups = 1;
    
    O = M;
  case 'fit'
    params = varargin{2};
    data = varargin{3};
    
    subMeans = params(1) + params(3:5);
    condMeans = params(end) * [1,-1];
    subMeanList = subMeans(data(:,2));
    condMeanList = condMeans(data(:,3));
    
    meansAll = subMeanList + condMeanList;
    
    O = MODEL.calc_safeLL(normpdf(data(:,1),meansAll',1));
  case 'pred'
    O = nan;

end
end