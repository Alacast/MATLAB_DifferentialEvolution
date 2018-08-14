function model = mlb_loadModel(model)
% looks in the current directory for the folder 'modelSaves' and grabs the
% most recent model object with the name 'name'

mFolder = [pwd filesep model.names.self filesep];
fDir = dir(mFolder);

if length(fDir) > 2
  try
    MM = load([mFolder model.names.self]);
    model = MM.model;
  catch
    model = [];
  end
  
else
  disp('NO MODEL FILES FOUND')
  model = [];
end