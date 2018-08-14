function chain = mlb_loadChain(model)

%% File Import Settings

chain = [];

foldHome = [pwd filesep model.names.self filesep 'chainSave' filesep];
fileHeads = {'params','likelihoods','predictions',...
  'pairwise_predictions','pairwise_parameters','AIC','kept','mode'};


fmtSpecs = {[repmat('%f, ', 1, model.n.params),'\n'];...
  [repmat('%f,', 1, 2+model.n.conditions),'\n'];...
  [repmat('%f,' , 1, model.n.predictions),'\n'];...
  [repmat('%f,' , 1, size(model.comparisons.pairwise.predictions.conditions,1)),'\n'];...
  [repmat('%f,' , 1, size(model.comparisons.pairwise.parameters.comparisons,1)),'\n'];...
  ['%f, \n'];...
  ['%f, \n'];...
  ['%f, \n']};


tI = 1:model.settings.n.steps:model.settings.n.steps*model.settings.n.chains;
tI = [tI;tI+model.settings.n.steps-1];
tbI = 1:model.settings.n.steps-model.settings.sampling.nBurnin:(model.settings.n.steps-model.settings.sampling.nBurnin)*model.settings.n.chains;
tbI = [tbI;tbI+model.settings.n.steps-model.settings.sampling.nBurnin-1];
for f = 1:length(fileHeads)
  temp = nan(model.settings.n.chains*model.settings.n.steps,length(strfind(fmtSpecs{f,:},'f')));
  tempBurn = nan(model.settings.n.chains*(model.settings.n.steps-model.settings.sampling.nBurnin),...
    length(strfind(fmtSpecs{f,:},'f')));
  for c = 1:model.settings.n.chains
    fName = [foldHome model.names.self '_' fileHeads{f} '_' num2str(c) '.txt'];
    fID = fopen(fName,'r');
    spec = fmtSpecs{f,:};
    spec = strrep(spec,'\n','');
    % sometimes we didn't store some files, so skip these
    if ~isempty(spec)
      data = cell2mat(textscan(fID,spec));
      dataBurn = data(model.settings.sampling.nBurnin+1:end,:);
    else
      data = [];
      dataBurn = [];
    end
    fclose(fID);
    temp(tI(1,c):tI(2,c),:) = data;
    tempBurn(tbI(1,c):tbI(2,c),:) = dataBurn;
  end
  eval(['chain.' fileHeads{f} ' = temp;'])
  eval(['chain.' [fileHeads{f} '_burn'] ' = tempBurn;'])
end
end