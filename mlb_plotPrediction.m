function mlb_plotPrediction(model,chain)

if ~isempty(model.function.postpredict)
  eval([model.function.sim '(model,chain);'])
end
end