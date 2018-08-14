function params = mlb_metropHastings(params,model.settings)
params = params + (model.settings.sampling.variance * randn(1,length(params)));
params = min(1,max(0,params));
end