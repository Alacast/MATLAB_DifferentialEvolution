function mlb_showPosterior(model,varargin)

if nargin < 3
  params = 1:model.n.params;
else
  params = varargin{1};
end

plotCol = cbrewer('seq','Blues',1)' * [0; 0; 1];

f.H = fig(100,'cf');
f.H.MenuBar = 'none';
f.H.NumberTitle = 'off';
% f.H.ButtonDownFcn = @buttonDown;

f.SP(1).H = subplot(10,1,1);
f.SP(2).H = subplot(10,1,3:10);
f.SP(1).H.NextPlot = 'add';
f.SP(1).H.Visible = 'off';
f.SP(2).H.NextPlot = 'add';
f.SP(2).H.Visible = 'off';


%% Menus to select parameter
Menus(1).H = uimenu('Parent',f.H,'Label','Select Parameter','Callback',@show);
% for p = 1:length(params)
%   Menus(p+1).H = uimenu('Parent',Menus(1).H,'Label',char(model.names.params(p)),...
%     'callback',@show,'UserData',p);
% end

% Menus(p+1).H = uimenu('Parent',Menus(1).H,'Label','Select Parameter',...
%     'callback',@show,'UserData',1);
%
%% Keyboard buttons



%% Functions
  function show(h,~)
    f.SP(1).H.Visible = 'on';
    f.SP(2).H.Visible = 'on';
    
    pNum = listdlg('PromptString','Select a parameter:',...
      'SelectionMode','single','ListString',model.names.params);
    
    %     pNum = h.UserData;
    
    
    if ~isempty(pNum)
      %% prior
      cla(f.SP(1).H);
      pri = model.bayes.priors(pNum,:);
      
      priEdge = icdf(pri{1},[.01 .99],pri{2},pri{3});
      priX = linspace(priEdge(1),priEdge(2),100);
      priL = pdf(pri{1},priX,pri{2},pri{3});
      plot(f.SP(1).H,priX,priL)
      %% posterior
      cla(f.SP(2).H);
      
      
      f.Name = [num2str(pNum) ': ' char(model.names.params(pNum))];
      post = model.bayes.posteriors.parameters.fit(pNum);
      
      hdi = post.HDIedges;
      % plot histogram
      xRange = post.plotEdges;
      xRange = [xRange(1)-.01*diff(xRange), xRange(2)+.01*diff(xRange)];
      xVals = linspace(xRange(1),xRange(2),50);
      [y,x] = hist(post.values,xVals);
      b = bar(f.SP(2).H,x,y./sum(y));
      b.FaceColor = plotCol;
      % show fit
      yFit = normpdf(x,post.mu,post.sig);
      plot(f.SP(2).H,x,yFit./sum(yFit),'k:','linewidth',2)
      
      
      
      % show hdi underneath
      yl = ylim;
      hdiHig = .1*diff(yl);
      cornersX = [hdi(1) hdi(1) hdi(2) hdi(2)];
      cornersY = [-hdiHig 0 0 -hdiHig];
      pa = patch(f.SP(2).H,cornersX,cornersY,plotCol','faceAlpha',.5);
      % lines
      %     l1 = plot(f.SP(2).H,ones(1,100)*hdi(1),linspace(0,yl(2),100),':','color',[.5 .5 .5],...
      %       'linewidth',2);
      %     l2 = plot(f.SP(2).H,ones(1,100)*hdi(2),linspace(0,yl(2),100),':','color',[.5 .5 .5],...
      %       'linewidth',2);
      % text
      % hdi
      t1 = text(f.SP(2).H,hdi(1),-.5*hdiHig,roundDec(hdi(1),2),...
        'horizontalalignment','left','fontsize',12);
      t2 = text(f.SP(2).H,hdi(2),-.5*hdiHig,roundDec(hdi(2),2),...
        'horizontalalignment','right','fontsize',12);
      % title
      
      f.SP(2).H.FontSize = 16;
      tit = title(f.SP(2).H,model.names.params(pNum),'units','normalized','position',[.5 .95 1],...
        'horizontalalignment','center','fontsize',20);
      % f.SP(2).His config
      f.SP(2).H.XLim = post.plotEdges;
      f.SP(2).H.YLim = [-1.5*hdiHig yl(2)];
      % summary
      modeText = text(f.SP(2).H,.8 ,.9, ['Mode = ' roundDec(post.mode,2)],'units','normalized',...
        'horizontalalignment','left','fontsize',14,'backgroundcolor',[ 1 1 1]);
      meanText = text(f.SP(2).H,.8 ,.85, ['Mean = ' roundDec(post.mu,2)],'units','normalized',...
        'horizontalalignment','left','fontsize',14,'backgroundcolor',[ 1 1 1]);
      sigmaText = text(f.SP(2).H,.8 ,.8, ['SD = ' roundDec(post.sig,2)],'units','normalized',...
        'horizontalalignment','left','fontsize',14,'backgroundcolor',[ 1 1 1]);
      
      xlabel('\theta')
      ylabel('Pr(\theta | Data)')
      drawnow
      
      
      %% automatically export
      figDir = [pwd filesep 'figures' filesep 'mlb_showPosterior' filesep];
      if ~exist(figDir,'dir')
        mkdir(figDir)
      end
      modelNoSlash = strrep(model.names.params{pNum},'\','');
      figName = [model.names.self,'_',num2str(pNum),'_',modelNoSlash];
      export_fig([figDir figName '.png'],'-nocrop');
    end
  end

end