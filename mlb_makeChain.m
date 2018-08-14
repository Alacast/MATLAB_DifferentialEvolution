function chain = mlb_makeChain(model)

% initialize main
chain.params = nan(model.settings.n.chains,model.n.params,model.settings.n.steps);
chain.likelihoods = nan(model.settings.n.chains,3,model.settings.n.steps);
chain.predictions = nan(model.settings.n.chains,model.n.predictions,model.settings.n.steps);

% initialize pairwise
npParam = size(model.comparisons.pairwise.parameters.comparisons,1);
npPred = size(model.comparisons.pairwise.predictions.conditions,1);

chain.pairwise_parameters = nan(model.settings.n.chains,npParam,model.settings.n.steps);
chain.pairwise_predictions = nan(model.settings.n.chains,npPred,model.settings.n.steps);

% accept-rekect
chain.kept = nan(model.settings.n.chains,1,model.settings.n.steps);

% initialize model comparison stats
chain.AIC = nan(model.settings.n.chains,1,model.settings.n.steps);

% keep track of which modes were used
chain.mode = nan(model.settings.n.chains,1,model.settings.n.steps);
end