function model = model_1dBinomial
% model construction
model.names.self = ['1dBinomial'];
model.names.spec = '';
% here using mean constrasts, sum to 0 is ~automatic
model.names.params = {...
 'p'}

  
   % functions to run
model.function.sim = 'ex3_1dBinomial';
model.function.convert = '';
% information for sampling
model.bayes.priors = [...  
  {'beta',1 1}];...  ]; % broad normal for all params 


% counts
model.n.predictions = 10000;%3341;
model.n.df = 6;
% settings44
model.settings.n.chains = 1;%250;
model.settings.n.groups = 1;
model.settings.n.steps = 1000;%0;
model.settings.sampling.pMutate = .5; %.1
model.settings.sampling.pBurnin = .5;
% parallel
if model.settings.n.chains > 1
  model.settings.useParallel = 1;
else
  model.settings.useParallel = 0;
  model.settings.sampling.pMutate = 1;
end
model = mlb_prepareModel(model);


%%
model.settings.sampling.usePrevious = 1;