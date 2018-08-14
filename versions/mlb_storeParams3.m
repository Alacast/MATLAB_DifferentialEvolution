function model = mlb_storeParams3(model,prop,t,mode)
%%
% if the proposed set of parameters was accepted (kept == 1), then store
% these values in each field at current time t, otherwise, move values from
% t-1 into current time.

%% File names

foldHome = [pwd filesep model.names.self filesep 'chainSave' filesep];
fieldNames = {'params','likelihoods','prediction','pairwise_predictions','pairwise_parameters','AIC'};
% they will always be nSteps x Z where Z changes depending on the
% type of data being stored. save that Z in a matrix
fieldSizes = [model.n.params,... % params
  2 + model.n.conditions,... % likelihoods
  model.n.predictions,... % predictions
  size(model.comparisons.pairwise.predictions.conditions,1),... % pair predict
  size(model.comparisons.pairwise.parameters.comparisons,1),... % pair param
  1]; % AIC


%%
switch mode
  case 'init'
    
    fclose('all');
    
    if ~exist(foldHome,'dir')
      mkdir(foldHome)
    end
    % delete any old files to ensure no confusion with past runs
    filePattern = fullfile(foldHome, '*.dat');
    fileDir = dir(filePattern);
    for f = 1:length(fileDir)
      fullFName = [foldHome fileDir(f).name];
      delete(fullFName)
    end
    
    % the first time running through, open the files used to store chains
    for c = 1:model.settings.n.chains
      for f = 1:length(fieldNames)
        fName = [foldHome 'c_' num2str(c) '_' fieldNames{f} '.dat'];
        fID = fopen(fName,'W');
        fwrite(fID,nan(model.settings.n.steps,fieldSizes(f)),'double');
        fclose(fID);
        if fieldSizes(f) > 0
          m = memmapfile(fName,...
            'Format',{'double',[1 fieldSizes(f)],fieldNames{f}},...
            'Repeat',model.settings.n.steps,...
            'Writable',true);
          model.save.memMaps{c,f} = m.Data;
        end
      end
    end
  case 'save'
    % during the run, store values in appropriate files
    for c = 1:model.settings.n.chains
      for f = 1:length(fieldNames)
        m = model.save.memMaps{c,f};
        if fieldSizes(f) > 0
          m(t).(fieldNames{f}) = prop.(fieldNames{f})(c,:);
        end
      end
    end
    
  case 'close'
    % after the last run, close all the files
    fclose('all');
end
