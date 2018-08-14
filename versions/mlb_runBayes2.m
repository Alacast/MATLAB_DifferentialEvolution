function model = mlb_runBayes2(model,data)

%% Prepare the model with basic information
model = mlb_prepareModel(model);

rng('shuffle')
%% Parallel
[pool,useParallel] = mlb_checkParallel(model);

%% Progress bar
progressbar(model.names.self);
%% Setup output files
mlb_storeParams(model,[],'init');
%% Elapsed Time
tic
%% First iteration
prev.params = nan;
prev = mlb_getProposal(model,prev,1);
prev.convParams = mlb_convertParams(model,prev.params);
logLike = nan(model.settings.n.chains,model.n.conditions);
prediction = nan(model.settings.n.chains,model.n.predictions);
progressbar(1/model.settings.n.steps);
% initialize the chain
chain = mlb_makeChain(model);

switch useParallel
  case 1
    p = prev.convParams;
    parfor c = 1:model.settings.n.chains
      params = p(c,:);
      [logLike(c,:),prediction(c,:)] = mlb_calcLike(model,params,data);
    end
  case 0
    for c = 1:model.settings.n.chains
      params = prev.convParams(c,:);
      [logLike(c,:),prediction(c,:)] = mlb_calcLike(model,params,data);
    end
end
prev.logLike = logLike;
prev.prediction = prediction;
prev.pairwise = mlb_pairwise(model,prev);
prev = mlb_calcPrior(model,prev);
prev = mlb_calcPosterior(prev);
prev = mlb_calcAIC(model,prev);
prev.kept = ones(model.settings.n.chains,1);
chain = mlb_updateChain(chain,prev,1);
%% Remaining iterations
percent1 = max(1,round(.01*model.settings.n.steps));

for t = 2:model.settings.n.steps
  % only show progressbar if it's 1 full percent of the progress
  if ~rem(t,percent1)
    progressbar(t/model.settings.n.steps);
  end
  prop.logPrior = inf;
  
  if ~rem(t,50)
    ts = max(1,t-50):t-1;
    model.settings.sampling.variance = min(10,max(1e-7,model.settings.sampling.variance .* ...
      2.^(((mean(chain.kept(:,:,ts),3)-.234)/.234))));
%     if mean(chain.kept(:,:,ts)) < .05; keyboard;end
% model.settings.sampling.variance
  end
  %     model.settings.sampling.variance
  %   end
  
  % % %   % compute the covariance matrix for adaptive step size
  % % %   for c = 1:model.settings.n.chains
  % % %     if t > 2
  % % %       prev.cov{c} = cov(reshape(chain.params(c,:,1:t-1),[t-1,model.n.params]));
  % % %     else
  % % %       prev.cov{c} = model.settings.sampling.variance;
  % % %     end
  % % %   end
%   while isinf(prop.logPrior)
    prop = mlb_getProposal(model,prev,t);
    prop.convParams = mlb_convertParams(model,prop.params);
    prop = mlb_calcPrior(model,prop);
%   end
  logLike = nan(model.settings.n.chains,model.n.conditions);
  prediction = nan(model.settings.n.chains,model.n.predictions);
  %   if useGPU
  %     g = gpuDevice;
  % %     reset(g);
  %   end
  switch useParallel
    case 0
      for c = 1:model.settings.n.chains
        params = prop.convParams(c,:);
        [logLike(c,:),prediction(c,:)] = mlb_calcLike(model,params,data);
      end
    case 1
      p = prop.convParams;
      parfor c = 1:model.settings.n.chains
        params = p(c,:);
        [logLike(c,:),prediction(c,:)] = mlb_calcLike(model,params,data);
      end
  end
  
  
  prop.logLike = logLike;
  prop.prediction = prediction;
  prop.pairwise = mlb_pairwise(model,prop);
  prop = mlb_calcPosterior(prop);
  prop = mlb_calcAIC(model,prop);
  
  prev = mlb_acceptReject(model,prop,prev);
  
  chain = mlb_updateChain(chain,prev,t);
  %   figure(3)
  %   plot(squeeze(chain.params)')
  %   drawnow
end

% if useParallel
%   delete(pool)
% end
model.settings.runTime = toc/60;
disp(['Time Elapsed: ' num2str(model.settings.runTime) ' minutes'])
mlb_storeParams(model,chain,'save');