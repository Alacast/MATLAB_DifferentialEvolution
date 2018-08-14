function model = mlb_GUImakeModel
% gui interface for making a new model from scratch

% % % init % % %
model = [];
Q = [];

% % % figure % % %
f.h = figure(1000); clf

% % % text boxes % % %
ui(1) = uicontrol();
ui(1).Tag = 'modelName';
ui(1).Parent = f.h;
ui(1).Style = 'edit';
ui(1).String = 'Model Name:';
ui(1).Units = 'normalized';
ui(1).Position = [.1 .8 .8 .1];

%
ui(2) = uicontrol();
ui(2).Tag = 'nParams';
ui(2).Parent = f.h;
ui(2).Style = 'edit';
ui(2).String = 'Number of Parameters';
Q.nParams = 1;
ui(2).Units = 'normalized';
ui(2).Position = [.1 .6 .8 .1];
ui(2).Callback = @fcn_nParams;



  function fcn_nParams(h,o)
    newN = str2num(h.String);
    if ~isempty(newN)
      Q.nParams = str2num(h.String);
    else
      h.String = '1';
      Q.nParams = 1;
      errordlg('nParams must be an integer');
    end
  end

  
end