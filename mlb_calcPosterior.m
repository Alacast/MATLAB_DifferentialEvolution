function prop = mlb_calcPosterior(prop)
% multiply prior * likelihood by summing logPrior + logLikelihood

prop.logPost = prop.logPrior + sum(prop.logLike,2);
if any(prop.logPost == 0)  
  prop.logPost(prop.logPost == 0) = -inf;
end