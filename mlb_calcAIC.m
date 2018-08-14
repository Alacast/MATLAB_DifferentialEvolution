function prop = mlb_calcAIC(model,prop)

%% AIC fcn
% prevent infs
prop.logPost(isinf(prop.logPost)) = -1e20;

prop.AIC = (2*model.n.params) - (2*prop.logLike);
end