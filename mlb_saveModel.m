function mlb_saveModel(model)
% saves a model object into the default folder which is:
% the current directory + \modelSaves



try
  outDir = [pwd filesep model.names.self filesep];
  fName = model.names.self; % append a space  
  % check to see if the appropriate file exists or not
  if ~exist(outDir,'dir')
    mkdir(outDir)
  end
  save([outDir, fName],'model')
catch err
  keyboard
  disp('ERROR WHILE SAVING MODEL')
end
end