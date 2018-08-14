function MC = mlb_calcDIC(MC)

%% DIC fcn
nModels = length(MC.models);
for m = 1:nModels
  % load the chain
  chain = mlb_loadFiles(MC.models(m));
  % compute the expectation of the loglikelihood across all of the steps.
  % In other words, the mean of the log likelihood function
  Dbar = mean(-2 * chain.likelihoods_burn(:,3));
  % compute the loglikelihood function with the expected parameter values
  thetaHat = mean(chain.params_burn);
  LL = mlb_calcLike(MC.models(m),thetaHat,MC.data);
  DthetaBar = -2*LL;
  % calculate pD
  pD = Dbar - DthetaBar;
  % and finally DIC
  MC.models(m).bayes.DIC = DthetaBar + (2*pD);
end
end