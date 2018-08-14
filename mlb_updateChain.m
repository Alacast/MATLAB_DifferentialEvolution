function chain = mlb_updateChain(chain,prev,t)
% updates the chain with the newest values

chain.params(:,:,t) = prev.params;
chain.likelihoods(:,:,t) = [prev.logPrior,prev.logPost,prev.logLike];
chain.predictions(:,:,t) = prev.prediction;

chain.pairwise_parameters(:,:,t) = prev.pairwise.parameters;
chain.pairwise_predictions(:,:,t) = prev.pairwise.predict;

chain.kept(:,:,t) = prev.kept;

chain.AIC(:,:,t) = prev.AIC;

chain.mode(:,:,t) = prev.mode;