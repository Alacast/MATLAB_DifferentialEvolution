function chain = mlb_loadChain2(model)

%% File Import Settings

chain = [];

foldHome = [pwd filesep model.names.self filesep 'chainSave' filesep];
fileHeads = {'params','likelihoods','predictions','pairwise_predictions','pairwise_parameters','AIC','kept'};


fmtSpecs = {[repmat('%f ', 1, model.n.params),'\n'];...
  [repmat('%f ', 1, 2+model.n.conditions),'\n'];...
  [repmat('%f ' , 1, model.n.predictions),'\n'];...
  [repmat('%f ' , 1, size(model.comparisons.pairwise.predictions.conditions,1)),'\n'];...
  [repmat('%f ' , 1, size(model.comparisons.pairwise.parameters.comparisons,1)),'\n'];...
  ['%f \n']};

for f = 1:length(fileHeads)
  temp = [];
  tempBurn = [];
  for c = 1:model.settings.n.chains
    fName = [foldHome model.names.self '_' fileHeads{f} '_' num2str(c) '.txt'];   
    
    % load the data
    data = table2array(readtable(fName,'ReadVariableNames',0));
    % pull out burn-in portion
    dataBurn = data(model.settings.sampling.nBurnin+1:end,:);
    
    temp = [temp ; data];
    tempBurn = [tempBurn ; dataBurn];
  end
  eval(['chain.' fileHeads{f} ' = temp;'])
  eval(['chain.' [fileHeads{f} '_burn'] ' = tempBurn;'])
end
end