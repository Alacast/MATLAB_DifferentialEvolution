function [LL,pred] = run_1dNormal(model,params,data)

like = normpdf(data,params(1),params(2));
logLike = log(like);
LL = sum(logLike);

% pred
pred = normrnd(params(1),params(2),model.n.predictions,1);