function model = mlb_storeParams(model,chain,mode)
%%
% if the proposed set of parameters was accepted (kept == 1), then store
% these values in each field at current time t, otherwise, move values from
% t-1 into current time.

global SAVE

%% File names

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

%%
switch mode
  case 'init'
    fclose('all');
    
    if ~exist(foldHome,'dir')
      mkdir(foldHome)
    end
    
    % save the prior params
    if model.settings.sampling.usePrevious
      oldModel = mlb_loadModel(model);
      try
        oldChain = mlb_loadChain(oldModel);
        [~,bestP] = max(oldChain.likelihoods_burn);
        bestP = bestP(3);
        model.settings.sampling.previousParams = oldChain.params_burn(bestP,:);
        model.settings.sampling.variance = oldModel.settings.sampling.variance;
        model.settings.sampling.varianceScaled = oldModel.settings.sampling.varianceScaled;
      catch
        model.settings.sampling.usePrevious = 0;
      end
    end
    
    % delete any old files to ensure no confusion with past runs
    
    filePattern = fullfile(foldHome, '*.txt');
    fileDir = dir(filePattern);
    for f = 1:length(fileDir)
      fullFName = [foldHome fileDir(f).name];
      delete(fullFName)
    end
    
    % the first time running through, open the files used to store chains
    for c = 1:model.settings.n.chains
      for f = 1:length(fileHeads)
        fName = [foldHome model.names.self '_' fileHeads{f} '_' num2str(c) '.txt'];
        fID = fopen(fName,'W');
        SAVE.(fileHeads{f}).fName{c} = fName;
        %         SAVE.(fileHeads{f}).fID(c) = fID;
        fclose(fID);
      end
    end
    
  case 'save'
    % during the run, store values in appropriate files
    for c = 1:model.settings.n.chains
      for f = 1:length(fileHeads)
        switch f
          case 1
            data = squeeze(chain.params(c,:,:));
          case 2
            data = squeeze(chain.likelihoods(c,:,:));
          case 3
            data = squeeze(chain.predictions(c,:,:));
          case 4
            data = squeeze(chain.pairwise_predictions(c,:,:));
          case 5
            data = squeeze(chain.pairwise_parameters(c,:,:));
          case 6
            data = squeeze(chain.AIC(c,:,:));
          case 7
            data = squeeze(chain.kept(c,:,:));
          case 8
            data = squeeze(chain.mode(c,:,:));
        end
        
        %         fID = SAVE.(fileHeads{f}).fID(c);
        fID = fopen(SAVE.(fileHeads{f}).fName{c},'w');
        fprintf(fID,fmtSpecs{f,:},data);
        fclose(fID);
      end
    end
  case 'close'
    % after the last run, close all the files
    fclose('all');
end
