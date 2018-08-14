function [LL,pred] = ex3_1dBinomial(model,params,data)

LL = sum(log(max(1e-20,binopdf(data.X,data.N,params(1)))));
pred =nan;% binornd(length(data),params(1));