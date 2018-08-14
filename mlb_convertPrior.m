function [v1,v2] = mlb_convertPrior(model,params,p)
keyboard
v1 = model.bayes.priors{p,2};
v2 = model.bayes.priors{p,3};
if ~isnumeric(v1) && ~isnumeric(v2)
  v1 = [];
  v2 = [];
  eval(['v1 = ' model.bayes.priors{p,2} ';'])
  eval(['v2 = ' model.bayes.priors{p,3} ';'])
end

end