% run_1dBinomial
p = .2;
data.N = 100;
nTrials = 1000;
data.X = binornd(N,p,nTrials,1);

model = model_1dBinomial;
model.data = data;


%% FIT MODEL
% go run it
model = mlb_runBayes(model,model.data);
model = mlb_getDiagnostics(model);
% write out the model object for later reference
mlb_saveModel(model)


%%
% store to Q
chain = mlb_loadChain(model);

%%
mlb_plotBayes(model,chain);