function smh_autoExport(str,varargin)

% by default this exports to the current directory, then /figures/. If we
% want to go deeper, say to "/figures/test/myfigures/" then add an
% additional argument that adds this info
if nargin > 1
  xtraFolders = varargin{1};
else
  xtraFolders = '';
end

global exportMe
if isempty(exportMe)
  response = questdlg('Export Figures?','Make a choice:','Yes','No','Yes');
  
  switch response
    case 'Yes'
      exportMe = 1;
    case 'No'
      exportMe = 2;
  end
end


if exportMe == 1
  figDir = [pwd filesep 'figures' filesep xtraFolders];
  % remove double \\
  figDir = strrep(figDir,[filesep filesep],filesep);
  
  if ~exist(figDir,'dir')
    mkdir(figDir)
  end
  
  if ~isempty(str)
    export_fig([figDir str '.png'],'-nocrop');
  end
  
end
end