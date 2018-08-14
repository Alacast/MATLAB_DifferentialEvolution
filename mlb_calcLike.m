function [LL,PRED] = mlb_calcLike(model,params,data)

eval(['[LL,PRED] = ' model.function.sim '(model,params,data);'])

end