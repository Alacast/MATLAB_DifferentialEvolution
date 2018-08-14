function model = mlb_runBayes3(model,data)

%% Prepare the model with basic information
model = mlb_prepareModel(model);

rng('shuffle')
%% Parallel
poolobj = gcp('nocreate'); % If no pool, do not create new one.
useParallel = ~isempty(poolobj);
%% Progress bar
progressbar(model.names.self);
%% Setup output files
model = mlb_storeParams3(model,[],[],'init');

%% First iteration
prev.params = nan;
prev = mlb_getProposal(model,prev,1);
logLike = nan(model.settings.n.chains,model.n.conditions);
prediction = nan(model.settings.n.chains,model.n.predictions);
progressbar(1/model.settings.n.steps);
% initialize the chain

switch useParallel
  case 1
    parfor c = 1:model.settings.n.chains
      params = prev.params(c,:);
      [logLike(c,:),prediction(c,:)] = mlb_calcLike(model,params,data);
    end
  case 0
    for c = 1:model.settings.n.chains
      params = prev.params(c,:);
      [logLike(c,:),prediction(c,:)] = mlb_calcLike(model,params,data);
    end
end
prev.logLike = logLike;
prev.prediction = prediction;
prev.pairwise = mlb_pairwise(model,prev);
prev = mlb_calcPrior(model,prev);
prev = mlb_calcPosterior(prev);
prev = mlb_calcAIC(model,prev);

% organize fields for storage
prev.likelihoods = [prev.logPrior,prev.logPost,prev.logLike];
prev.pairwise_predictions = prev.pairwise.predict;
prev.pairwise_parameters = prev.pairwise.parameters;

model = mlb_storeParams3(model,prev,1,'save');
%% Remaining iterations
percent1 = round(.01*model.settings.n.steps);

for t = 2:model.settings.n.steps
  % only show progressbar if it's 1 full percent of the progress
  if ~rem(t,percent1)
    progressbar(t/model.settings.n.steps);
  end
  prop = mlb_getProposal(model,prev,t);
  prop = mlb_calcPrior(model,prop);
  logLike = nan(model.settings.n.chains,model.n.conditions);
  prediction = nan(model.settings.n.chains,model.n.predictions);
  %   if useGPU
  %     g = gpuDevice;
  % %     reset(g);
  %   end
  switch useParallel
    case 0
      for c = 1:model.settings.n.chains
        params = prop.params(c,:);
        %         % only run if the parameters are valid (prior probability > 0)
        %         if ~isinf(prop.logPrior(c,:))
        [logLike(c,:),prediction(c,:)] = mlb_calcLike(model,params,data);
        %         else
        %           logLike(c,:) = -inf; prediction(c,:) = zeros(1,model.n.predictions);
        %         end
      end
    case 1
      %       parfor c = 1:model.settings.n.chains
      spmd
        params = prop.params(labindex,:);
        %         % only run if the parameters are valid (prior probability > 0)
        %         if ~isinf(prop.logPrior(c,:))
        [LL,P] = mlb_calcLike(model,params,data);
        %         else
        %           logLike(c,:) = -inf; prediction(c,:) = zeros(1,model.n.predictions);
        %         end
      end
      % unpack
      for c = 1:model.settings.n.chains
        logLike(c,:) = LL{c};
        prediction(c,:) = P{c};
      end
  end
  
  
  prop.logLike = logLike;
  prop.prediction = prediction;
  prop.pairwise = mlb_pairwise(model,prop);
  prop = mlb_calcPosterior(prop);
  prop = mlb_calcAIC(model,prop);
  
  prev = mlb_acceptReject(model,prop,prev);
  
  % organize fields for storage
  prev.likelihoods = [prev.logPrior,prev.logPost,prev.logLike];
  prev.pairwise_predictions = prev.pairwise.predict;
  prev.pairwise_parameters = prev.pairwise.parameters;
  
  model = mlb_storeParams3(model,prev,t,'save');
  
end

