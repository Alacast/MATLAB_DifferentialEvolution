function pairwise = mlb_pairwise(model,prop)
pairwise.predict = nan(model.settings.n.chains,size(model.comparisons.pairwise.predictions.conditions,1));

for c = 1:model.settings.n.chains
  for p = 1:size(model.comparisons.pairwise.predictions.conditions,1)
    c1 = model.comparisons.pairwise.predictions.conditions(p,1);
    c2 = model.comparisons.pairwise.predictions.conditions(p,2);
    pairwise.predict(c,p) = prop.prediction(c,c1) - prop.prediction(c,c2);
  end
end

%% parameters
logistic = @(x) 1 ./ (1+exp(-x));
pairwise.parameters = nan(model.settings.n.chains,size(model.comparisons.pairwise.predictions.conditions,1));
for c = 1:model.settings.n.chains
  convParams = mlb_convertParams(model,prop.params(c,:));
  for p = 1:size(model.comparisons.pairwise.parameters.comparisons,1)
    p1 = model.comparisons.pairwise.parameters.comparisons(p,1);
    p2 = model.comparisons.pairwise.parameters.comparisons(p,2);
    if ~any(isnan([p1,p2]))      
      params = [convParams(p1),convParams(p2)];
      pairwise.parameters(c,p) = diff(params);
    else
      pList = [p1,p2]; pListFilt = pList(~isnan(pList));
      chanceVal = model.comparisons.pairwise.parameters.values(p);
      ind = find(pListFilt == pList);
      switch ind
        case 2
          params = [chanceVal,convParams(pListFilt)];
        case 1
          params = [convParams(pListFilt),chanceVal];          
      end
      pairwise.parameters(c,p) = diff(params);
    end
  end
end

end