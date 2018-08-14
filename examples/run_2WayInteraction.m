function [LL,pred] = run_2WayInteraction(model,params,data)

b0 = params(1);
b1 = params(2)*[1,-1];
b2 = params(3)*[1,-1];
b1x2 = params(4)*[1,-1,-1,1];
mu = [b0+b1(data.Var1) + b2(data.Var2) + b1x2(data.Var1+2*(data.Var2-1))]';

like = normpdf(data.Var3,mu,1);
safeLike = max(1e-20,like);
logLike = log(safeLike);
LL = sum(logLike);

% pred
pred = normrnd(mu,1,size(data,1),1);