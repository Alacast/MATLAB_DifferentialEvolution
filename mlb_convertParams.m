function convP = mlb_convertParams(model,params)

if ~isempty(model.function.convert)
  eval(['convP = ' model.function.convert  '(model,params);'])
else
  convP = params;
end