function prop = mlb_tryParams(model,prop,data)
%%
% Given a set of potential parameters, run the model and calculate the 
% likelihood of the data (Pr(data|model)). Also generate a prediction of the
% data given the parameters. Compute the posterior as Prior * likelihood; 
% if requested, compute pairwise differences between params or conditions
%%
% calculate likelihood, generate prediction
[prop.logLike,prop.predict] = mlb_calcLike(model,prop.params,data);
% calculate posterior = prior * likelihood 
prop.logPost = sum(prop.logLike) + prop.logPrior;
% compute pairwise comparisons
% % prop.pairwise = mlb_calcPairwise(model,prop.predict);