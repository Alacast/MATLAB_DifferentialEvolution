function [LL,pred] = run_1dNormal(model,params,data)

LL = -normlike([params(1),params(2)],data);

% logLike = log(like);
% LL = sum(logLike);

% pred
pred = normrnd(params(1),params(2),size(data,1),1);