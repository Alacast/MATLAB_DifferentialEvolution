function [poolObj, useParallel] =  mlb_checkParallel(model)

poolObj = gcp('nocreate'); % get pool; if no pool, do not create new one.
localPool = parcluster('local');

nWorks = min(localPool.NumWorkers,model.settings.n.chains);

if model.settings.useParallel && model.settings.n.chains > 1  
  useParallel = 1;
  if isempty(poolObj)
    poolObj = parpool('local',nWorks);    
  end
else
  poolObj = [];
  useParallel = 0;
end