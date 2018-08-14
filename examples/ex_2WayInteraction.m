% mlb_ex1dNormal
% Example: fit standard normal

%% generate some fake data to fit
m0 = 1;
m1 = 2 *[1,-1];
m2 = 3 * [1,-1];
m12 = [4,-4,-4,4];
sd = 1;
nData = 1000;

facs1 = [zeros(nData/2,1);ones(nData/2,1)]+1;
facs2 = repmat([zeros(nData/4,1);ones(nData/4,1)]+1,2,1);

means = m0 + m1(facs1) + m2(facs2) + m12(facs1+2*(facs2-1));
data = normrnd(means,sd)';

dt = array2table([facs1,facs2,data]);
data = dt;
%% define a model
model = [];
model.names.self = 'ex2WayInteraction';
model.names.spec = 'y ~ N(mu,sig)';
model.names.params = {...
  '\mu0','\mu1','\mu2','\mu1x2'};
   
% functions to run
model.function.sim = 'run_2WayInteraction';
% information for sampling
model.bayes.priors = [...
  {'normal',0,10};... % broad normal for B0s  
  {'normal',0,10};... % broad normal for B0s  
  {'normal',0,10};... % broad normal for B0s  
  {'normal',0,10}]; % broad normal for B0s  
  
% counts
model.n.predictions = nData;
model.n.df = 1;

model = mlb_prepareModel(model);

model.settings.n.chains = 10;
model.settings.n.steps = 1000;

model.settings.sampling.pMutate = .1;

if model.settings.n.chains > 1
  model.settings.useParallel = 1;
else
  model.settings.useParallel = 0;
  model.settings.sampling.pMutate = 1;
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

mlb_showPosterior(model)

