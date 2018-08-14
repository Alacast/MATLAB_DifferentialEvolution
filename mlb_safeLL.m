function LL = mlb_safeLL(like)
% takes a vector of (potentially negative or otherwise dysfunctional)
% likelihoods and returns the total, correct log likelihood

safeLike = max(1e-20,like);
logSafeLike = log(safeLike);
LL = sum(logSafeLike);