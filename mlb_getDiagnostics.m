function model = mlb_getDiagnostics(model)
%%
% Calculate some diagnostic information after the chains are finised running.
% - get empirical posterior
% - fit normal to posterior
% - find the HDI
% - compute pairwise differences
%%


%% Loop through each model

  chain = mlb_loadChain(model);
  
  model.bayes.posteriors.parameters = postParams(model);
  model.bayes.posteriors.predictions = postPreds(model);
  if ~isempty(model.comparisons.pairwise.parameters.comparisons)
    model.bayes.posteriors.pairwise.parameters = calcPairwiseParams(model);
  end
  if ~isempty(model.comparisons.pairwise.predictions.conditions)
    model.bayes.posteriors.pairwise.predict = calcPairwisePredict(model);
  end
  %%%% SEE NOTE BELOW
%   if length(MC.models) > 1
%     model.bayes.posteriors.modelCompare = calcModelCompare;
%   end 

  function posteriors = postParams(model)
    nP = model.n.params;
    convParams = mlb_convertParams(model,chain.params_burn);
    if iscell(convParams)
      convMat = cell2mat(convParams);
    else
      convMat = convParams;
    end
    for p = 1:nP
      posteriors.fit(p) = calcHDI(convMat(:,p));
    end
  end

  function posteriors = postPreds(model)
    nP = model.n.predictions;
    preds = chain.predictions_burn;
    for p = 1:nP
      posteriors.fit(p) = calcHDI(preds(:,p));
    end
  end

  function pairwise = calcPairwiseParams(model)
    nC = size(model.comparisons.pairwise.parameters.comparisons,1);
%     convParams = mlb_convertParams(model,chain.pairwise_parameters_burn);
    convParams = chain.pairwise_parameters_burn;
    for p = 1:nC
      pairwise.fit(p) = calcHDI(convParams(:,p));
    end
  end

  function pairwise = calcPairwisePredict(model)
    nC = size(model.comparisons.pairwise.predictions.conditions,1);
    for p = 1:nC
      pairwise.fit(p) = calcHDI(chain.pairwise_predictions_burn(:,p));
    end
  end

  function fit = calcHDI(values)
    [fit.mu,fit.sig] = normfit(values);
    fit.HDIedges = norminv([.025 .975],fit.mu,fit.sig);
    fit.plotEdges = norminv([.001 .999],fit.mu,fit.sig);
    %
    fit.mode = mode(round(values,2));
    fit.values = values;
  end

%% NOTE MODEL COMPARISON REMOVED FROM THIS FUNCTIONALITY 
%   function compare = calcModelCompare
%     modComp = 1:length(MC.models);
%     modComp(modComp == m) = [];
%     for m2 = 1:length(modComp)
%       p = modComp(m2);
%       chain2 = mlb_loadFiles(MC.models(p));
%       compare.fit(p) = calcHDI(chain.AIC_burn-chain2.AIC_burn);
%     end
%   end

end