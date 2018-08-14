% mlb_ex1dNormal
% Example: fit standard normal

%% generate some fake data to fit
mu = 0;
sd = 1;
nData = 1000;

data = normrnd(mu,sd,[nData],1);

%% define a model
model = [];
model.names.self = 'ex1dNormal';
model.names.spec = 'y ~ N(mu,sig)';
model.names.params = {...
  '\mu','\sigma'};
   
% functions to run
model.function.sim = 'run_1dNormal';
% information for sampling
model.bayes.priors = [...
  {'normal',0,10};... % broad normal for B0s  
  {'unif',0,10}];   % broad normals for gaze effect
  
% counts
model.n.predictions = nData;
model.n.df = 1;

model = mlb_prepareModel(model);

model.settings.n.chains = 100;
model.settings.n.steps = 500;

model.settings.sampling.pMutate = .1;

if model.settings.n.chains > 1
  model.settings.useParallel = 1;
else
  model.settings.useParallel = 0;
end
  

%% fit the model
model = mlb_runBayes2(model,data);
model = mlb_getDiagnostics(model);
%% plot
chain = mlb_loadChain(model);
figure(1)
plot(chain.params_burn)
figure(2)
plot(chain.likelihoods_burn)
set(gca,'yscale','log')
mean(chain.kept)

