function model = mlb_runBayes(model,data)

%% Prepare the model with basic information
model = mlb_prepareModel(model);

rng('shuffle')
%% Parallel
[pool,useParallel] = mlb_checkParallel(model);

%% Progress bar
progressbar(model.names.self);
%% Setup output files
model = mlb_storeParams(model,[],'init');
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
    prAccepted = mean(chain.kept(:,:,ts),3);
    acceptMinus234 = prAccepted - .234;
    newScale = logistic(acceptMinus234,5)+.5;
%     scaleAt234 = 1; scaleAt0 = .25; m = (scaleAt234-scaleAt0) ./ (.234);
%     scaleAt1 = .1; scaleAt0 = .001; m = (scaleAt1 - scaleAt0);
    newVar = max(1e-3,min(1e-1,newScale .* model.settings.sampling.variance));
    
%     deviationFromGoal = prAccepted - 0.234; % positive means more than we want
%     shiftBy = model.settings.sampling.variance .* (deviationFromGoal);
%     scaleShift = shiftBy * .1; %damper the oscillations
%     newVar = model.settings.sampling.variance + scaleShift
    
    model.settings.sampling.variance = newVar;
    
%     model.settings.sampling.variance = min(100,max(1e-7,model.settings.sampling.variance .* ...
%       2.^(((mean(chain.kept(:,:,ts),3)-.234)/.234))));

  end
  
    prop = mlb_getProposal(model,prev,t);
    prop.convParams = mlb_convertParams(model,prop.params);
    prop = mlb_calcPrior(model,prop);
%   end
  logLike = nan(model.settings.n.chains,model.n.conditions);
  prediction = nan(model.settings.n.chains,model.n.predictions);
  
  
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
drawnow
model.settings.runTime = toc/60;
model = mlb_storeParams(model,chain,'save');
model = mlb_getDiagnostics(model);

%% SAVE MODEL
mlb_saveModel(model);