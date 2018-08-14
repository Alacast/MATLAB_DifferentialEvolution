function mlb_runStats(model,mode)
% stores meta information regarding each run of mlb functions in the mlb_ home folder

homeDir = pwd;

textName = [homeDir '\runStats.txt'];
if ~exist(textName)
  dt = datestr(now);
  DT = strsplit(dt);
  colNames = [{'Date','Start Time','Model Name'];
  colNames = [DT(1), DT(2), {model.name}]
  textFID = fopen(textName,'a');
get(textFID)