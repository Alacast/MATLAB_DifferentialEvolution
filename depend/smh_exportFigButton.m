function smh_exportFigButton(figHandle,varargin)

% by default, will send off to smh_autoExport, which will send it off to
% the current directory, '\figures\'. If we want to go further, then we can
% specify an additional argument which includes more folders afterwards,
% e.g. '\figures\test\myFolder\'.
if nargin > 1
  xtraFolders = varargin{1};
else
  xtraFolders = '';
end

B.export_fig = uimenu();
B.export_fig.Parent = figHandle;
B.export_fig.Label = 'Export Fig';
B.export_fig.UserData = xtraFolders;
B.export_fig.Callback = {@callback,figHandle};

end

function callback(h,o,inFig)
if isempty(inFig.Name)
  figName = num2str(inFig.Number);
else
  figName = inFig.Name;
end
% select the right figure
figure(inFig)
smh_autoExport(figName,h.UserData);

msgbox('Figure exported');
end
