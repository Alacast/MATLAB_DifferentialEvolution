function MC = mlb_modelComparison(modelList,dataFcn)
% Fit each of the models in 'modelList' to the data found when running
% 'dataFcn.' Compute and diplay posteriors on the paramters, show posterior
% predictive checks, and return quantitative assessment.

%%% INPUTS
% modelList: 1xn cell containing strings of model names you wish to compare
% dataFcn: name of a function that will be used to load organized data into
%     memory during fitting
% model.settings: MCMC / Bayesian mlb_settings (e.g. number of chains etc)


%% Function Definitions

  function data = retrieveData(dataFcn)
    % runs the function 'dataFcn,' given as an initial argument to the
    % master function. This function should find an organized set of data
    % to which each model will be fit.
    data = [];
    eval(['data = ' dataFcn ';'])
  end

  function model = retrieveModel(mName)
    % runs the function 'mName' which loads and retrieves the specification
    % of a given model, and returns it to caller
    model = [];
    eval(['model = ' mName ';'])
  end
%% Run 
% try
  tic
  %% Initialize Models
  nModels = length(modelList);
  % load the model specifications into a structure
  for m = 1:nModels
    modName = modelList{m};
    MC.models(m) = retrieveModel(modName);
  end
  
  %% Load the Empirical Data
  MC.data = retrieveData(dataFcn);
  
  %% Run the Models
  % initialize a parallel pool if need be
  
  for m = 1:nModels
    mlb_checkParallel(MC.models(m));    
    mlb_runBayes(MC.models(m),MC.data);
  end
  
  %% Get Diagnostics
  for m = 1:nModels
    MC = mlb_getDiagnostics(MC);
  end
  
  %% Compute DIC
  MC = mlb_calcDIC(MC);
  
  %% Plot the outputs
  
  MC = mlb_showBayes(MC);

toc
end