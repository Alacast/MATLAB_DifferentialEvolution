function mlb2_showPosterior(model,paramAx)


plotCol = [.1922,.5098,.7412]';

%% Create interface
% % % grab handle for other figure % % %
f2.H = figure(201);
lineHandles = flip(findobj('Parent',paramAx{1},'Type','Line'));
highLine = [];

% % % setup figure % % %
f.H = figure(100);
clf(f.H); hold on
f.H.MenuBar = 'none';
f.H.NumberTitle = 'off';

% % % setup axes % % %
f.SP(1).H = subplot(10,1,1:10);
f.SP(1).H.NextPlot = 'add';
f.SP(1).H.Visible = 'off';


% % % menu to select parameter % % %
uimenu('Parent',f.H,'Label','Select Parameter','Callback',@select);
uimenu('Parent',f.H,'Label','Export Figures','Callback',@export_all);

pNum = [];
%% Functions

  function select(h,o)
     pNum = listdlg('PromptString','Select a parameter:',...
      'SelectionMode','single','ListString',model.names.params);
    show;
  end
  function show(h,o)
    f.SP(1).H.Visible = 'on';
    
    if ~isempty(pNum)
      
      %% posterior
      cla(f.SP(1).H);
      
      f.Name = [num2str(pNum) ': ' model.names.params{pNum}];
      post = model.bayes.posteriors.parameters(pNum);
      
      hdi = post.HDIedges;
      % plot histogram
      xRange = post.plotEdges;
      xRange = [xRange(1)-.01*diff(xRange), xRange(2)+.01*diff(xRange)];
      xVals = linspace(xRange(1),xRange(2),50);
      [y,x] = hist(post.values,xVals);
      b = bar(f.SP(1).H,x,y./sum(y));
      b.FaceColor = plotCol;
      axes_format(y./sum(y))
      % show fit
      yFit = normpdf(x,post.mu,post.sig);
      plot(f.SP(1).H,x,yFit./sum(yFit),'k:','linewidth',2)
      
      
      
      % show hdi underneath
      yl = ylim;
      hdiHig = .1*diff(yl);
      cornersX = [hdi(1) hdi(1) hdi(2) hdi(2)];
      cornersY = [-hdiHig 0 0 -hdiHig];
      pa = patch(f.SP(1).H,cornersX,cornersY,plotCol','faceAlpha',.5);
      
      % hdi
      t1 = text(f.SP(1).H,hdi(1),-.5*hdiHig,smh_roundDec(hdi(1),2),...
        'horizontalalignment','left','fontsize',12);
      t2 = text(f.SP(1).H,hdi(2),-.5*hdiHig,smh_roundDec(hdi(2),2),...
        'horizontalalignment','right','fontsize',12);
      % title
      
      f.SP(1).H.FontSize = 16;
      tit = title(f.SP(1).H,model.names.params(pNum),'units','normalized','position',[.5 .95 1],...
        'horizontalalignment','center','fontsize',20);
      % f.SP(1).His config
      f.SP(1).H.XLim = post.plotEdges;
      f.SP(1).H.YLim = [-1.5*hdiHig yl(2)];
      % summary
      modeText = text(f.SP(1).H,.8 ,.9, ['Mode = ' smh_roundDec(post.mode,2)],'units','normalized',...
        'horizontalalignment','left','fontsize',14,'backgroundcolor',[ 1 1 1]);
      meanText = text(f.SP(1).H,.8 ,.85, ['Mean = ' smh_roundDec(post.mu,2)],'units','normalized',...
        'horizontalalignment','left','fontsize',14,'backgroundcolor',[ 1 1 1]);
      sigmaText = text(f.SP(1).H,.8 ,.8, ['SD = ' smh_roundDec(post.sig,2)],'units','normalized',...
        'horizontalalignment','left','fontsize',14,'backgroundcolor',[ 1 1 1]);
      
      xlabel('\theta')
      ylabel('Pr(\theta | Data)')
      
      
      % % % highlight parameter % % %
      line_highlight(pNum)
      
      drawnow
      
      
      
      %% automatically export
      figDir = [pwd filesep 'figures' filesep model.names.self filesep];
      if ~exist(figDir,'dir')
        mkdir(figDir)
      end
      
      modelNoSlash = strrep(model.names.params{pNum},'\','');
      posteriorsDir = [figDir 'posteriors' filesep];
      if ~exist(posteriorsDir,'dir')
        mkdir(posteriorsDir)
      end
      
      figName = [model.names.self,'_',num2str(pNum),'_',modelNoSlash];
      export_fig([posteriorsDir figName '.png'],'-nocrop');
    end
  end

  function axes_format(y)
    f.SP(1).H.YLim = [0,1.25*max(y)];
    f.SP(1).H.YLim(1) = -0.1 * diff(f.SP(1).H.YLim);
  end

  function line_highlight(pNum)
    % we want to show the selected parameter more strongly, but it's not
    % enough to simply manipulate the properties of the existing line,
    % because, due to the order of plotting, it may be behind subsequent
    % lines that were plotted afterwards. Instead, make a copy of the
    % existing line and then plot it, overtop of the other lines.
    
    
    % delete the old highlighted line, if it exists
    try
      delete(highLine);
    end
    % grab all the properties of the line we want to duplicate
    hlInfo = lineHandles(pNum);
    hlFields = fieldnames(hlInfo);
    % create an empty plot object to manipulate
    highLine = plot(nan,nan);
    % copy over all of the info
    for ii = 1:length(hlFields)
      try
        highLine.(hlFields{ii}) = hlInfo.(hlFields{ii});
      end
    end
    % highlight this new line
    highLine.LineStyle = '-';
    highLine.LineWidth = 3;
  end

  function export_all(h,o)
    for pp = 1:model.settings.n.params
      pNum = pp;
      show([],[])
    end
  end

end