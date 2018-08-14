function prop = mlb_calcPrior(model,prop)
% Calculate the prior probabilities of the proposed parameter values

prop.logPrior = nan(model.settings.n.chains,model.n.params);


for p = 1:model.n.params
  prop.logPrior(:,p) = log(pdf(...
    model.bayes.priors{p,1},...
    prop.convParams(:,p),...
    model.bayes.priors{p,2},...
    model.bayes.priors{p,3}));
end


prop.logPrior = sum(prop.logPrior,2);