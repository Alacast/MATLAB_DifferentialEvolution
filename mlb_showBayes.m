function MC = mlb_showBayes(MC)
%%
% for each model, show summary information for each parameter (prior & posterior),
% do a posterior predictive check

%% Initialize
nModels = length(MC.models);
model.settings.n.chains = model.settings.n.chains;
cbrewNames = {'Reds','Oranges','YlGn','Greens','Blues','PuRd',...
  'Purples'};
% cbrewNames = {'RdYlGn','RdYlBu','RdGy','PuOr','PRGn','PiYG','BrBG'};


%% Loop through each model
for m = 1:nModels
  chain = mlb_loadFiles(MC.models(m));
  sortByFit
  plot_params
  plot_posteriorPrediction
  if ~isempty(MC.models(m).comparisons.pairwise.predictions.conditions)
    plot_contrasts
  end
  if ~isempty(MC.models(m).comparisons.pairwise.parameters.comparisons)
    plot_paramComp
  end
  if nModels > 1
    plot_modelCompare
  end
end
%%
  function sortByFit
    LPs = nan(1,model.settings.n.chains);
    chainEnds = [1:model.settings.n.chains]  * model.settings.n.steps;
    LPs = chain.likelihoods(chainEnds,2);
    [~,LPorder] = sort(LPs,'descend');
    MC.models(m).bayes.fitOrder = LPorder;
  end
%%
  function plot_params
    % open the figure
    MC.models(m).plotting.params = [];
    nRow = 3;
    nCol = MC.models(m).n.params;
    MC.models(m).plotting.parameters.handle = fig(MC.models(m).plotting.figBase+1,'cf');
    MC.models(m).plotting.parameters.handle.Units = 'normalized';
    MC.models(m).plotting.parameters.handle.Position = [1.01 .1 .3+.1*(nCol-1) .9];
    %
    %     sps = subplotSam(nRow,nCol,[.1 .1]);
    convParams = mlb_convertParams(MC.models(m),chain.params);
    for p = 1:nCol
      % colors
      cols = getColors(p,model.settings.n.chains);
      cols = cols(MC.models(m).bayes.fitOrder,:);
      darkestCol = find(min(sum(cols,2)) == sum(cols,2));
      
      % set up chains plotting
      MC.models(m).plotting.parameters.sp.handle(p,1) = subplot(nRow,nCol,p);
      %       MC.models(m).plotting.parameters.sp.handle(p,1) = get(sps(1,p));
      configureAxes('chain',MC.models(m).plotting.parameters.sp.handle(p,1),p,cols);
      title(MC.models(m).names.params{p},'fontsize',8,'fontweight','bold');
      
      % show prior - only for fixed priors (non-hierarchical)
      if isnumeric(MC.models(m).bayes.priors{p,2}) && isnumeric(MC.models(m).bayes.priors{p,3})
        MC.models(m).plotting.parameters.sp.handle(p,2) = subplot(nRow,nCol,p+nCol);
        %       MC.models(m).plotting.parameters.sp.handle(p,2) = sps(2,p);
        
        xEdge = icdf(MC.models(m).bayes.priors{p,1},[.001,.999],MC.models(m).bayes.priors{p,2},MC.models(m).bayes.priors{p,3});
        configureAxes('prior',MC.models(m).plotting.parameters.sp.handle(p,2),p,xEdge)
        
        xs = linspace(xEdge(1),xEdge(2),500);
        ys = pdf(MC.models(m).bayes.priors{p,1},xs,...
          MC.models(m).bayes.priors{p,2},...
          MC.models(m).bayes.priors{p,3});
        plot(xs,ys,'linewidth',1.2,'color',cols(darkestCol,:));
      end
      
      % show posterior
      MC.models(m).plotting.parameters.sp.handle(p,3) = subplot(nRow,nCol,p+2*nCol);
      %       MC.models(m).plotting.parameters.sp.handle(p,3) = sps(3,p);
      configureAxes('posterior',MC.models(m).plotting.parameters.sp.handle(p,3),p);
      plotHist(MC.models(m).bayes.posteriors.parameters.fit,p,2,...
        MC.models(m).comparisons.pairwise.parameters)
      
      % plot chains
      keepBegin = [model.settings.sampling.nBurnin:model.settings.n.steps:(model.settings.n.chains*model.settings.n.steps)]+1;
      keepEnd = [1:model.settings.n.chains] * model.settings.n.steps;
      for c = 1:model.settings.n.chains
        L(c) = patchline(1:(model.settings.n.steps-model.settings.sampling.nBurnin),convParams(keepBegin(c):keepEnd(c),p),...
          'edgealpha',.2,'edgecolor',cols(c,:),'linewidth',1.2,...
          'Parent',MC.models(m).plotting.parameters.sp.handle(p,1));
      end
    end
    
    axList = MC.models(m).plotting.parameters.sp.handle(:,3);
    linkaxes(axList,'y')
    %     MC.models(m).plotting.parameters.sp.handle(1,3).YLim(1) = -.01;
    MC.models(m).plotting.parameters.sp.handle(1,3).YLim(2) = 1.25 * MC.models(m).plotting.parameters.sp.handle(p,3).YLim(2);
  end

  function plot_posteriorPrediction
    try
      MC.models(m).plotting.posterior.handle = fig(MC.models(m).plotting.figBase+2,'cf');
      eval([MC.models(m).function.postPredict '(MC.models(m),MC.data);'])
    catch
      disp('Could not run post-predict function')
    end
  end
%%
  function plot_contrasts
    MC.models(m).plotting.contrast.handle = fig(MC.models(m).plotting.figBase+3,'cf');
    %
    nC = size(MC.models(m).comparisons.pairwise.predictions.conditions,1);
    for p = 1:nC
      MC.models(m).plotting.contrasts.predictions.sp.handle(p) = subplot_tight(2,nC/2,p,[.15 .05]);
      configureAxes('pairwisePredictions',MC.models(m).plotting.contrasts.predictions.sp.handle(p),p)
      plotHist(MC.models(m).bayes.posteriors.pairwise.predict.fit,p,0,...
        MC.models(m).comparisons.pairwise.predictions);
    end
    linkaxes(MC.models(m).plotting.contrasts.predictions.sp.handle,'y')
    MC.models(m).plotting.contrasts.predictions.sp.handle(1).YLim(2) = ...
      1.25 * MC.models(m).plotting.contrasts.predictions.sp.handle(1).YLim(2);
    %     MC.models(m).plotting.contrasts.sp(1).YLim(1) = -.01;
  end
%%
  function plot_modelCompare
    MC.models(m).plotting.modelCompare.handle = fig(MC.models(m).plotting.figBase+4,'cf');
    modComp = 1:length(MC.models);
    modComp(m) = [];
    for m2 = 1:length(modComp)
      MC.models(m).plotting.modelCompare.sp.handle(m2) = subplot_tight(1,length(modComp),m2,[.1 .1]);
      configureAxes('modelCompare',MC.models(m).plotting.modelCompare.sp.handle(m2),m2);
      %
      p = modComp(m2);
      %
      plotHist(MC.models(m).bayes.posteriors.modelCompare.fit,p,2);
    end
  end
%%
  function plot_paramComp
    MC.models(m).plotting.paramComp.handle = fig(MC.models(m).plotting.figBase+5,'cf');
    %
    nC = size(MC.models(m).comparisons.pairwise.parameters.comparisons,1);
    for p = 1:nC
      MC.models(m).plotting.contrasts.parameters.sp.handle(p) = subplot_tight(2,nC/2,p,[.15 .05]);
      configureAxes('pairwiseParameters',MC.models(m).plotting.contrasts.parameters.sp.handle(p),p)
      plotHist(MC.models(m).bayes.posteriors.pairwise.parameters.fit,p,2,...
        MC.models(m).comparisons.pairwise.parameters);
      xt = get(MC.models(m).plotting.contrasts.parameters.sp.handle(p),'xtick');
      xt2 = xt(1):.1:xt(end);
      set(MC.models(m).plotting.contrasts.parameters.sp.handle(p),'xtick',xt2);
    end
    linkaxes(MC.models(m).plotting.contrasts.parameters.sp.handle,'y')
    MC.models(m).plotting.contrasts.parameters.sp.handle(1).YLim(2) = ...
      1.25 * MC.models(m).plotting.contrasts.parameters.sp.handle(1).YLim(2);
  end
%%
  function plotHist(fit,p,prec,comp)
    try
      hdiEdges = fit(p).HDIedges;
      %
      plotEdges = fit(p).plotEdges;
      
      nBars = 25;
      xDiff = diff(hdiEdges)/nBars; % let's use 20 equally spaced bars to represent the HDI interval
      xHDIRange = linspace(hdiEdges(1),hdiEdges(2),nBars); % find where they should be located
      xLow = hdiEdges(1):-xDiff:min(fit(p).values); % also, using the same spacing, go to the min
      xHigh = hdiEdges(2):xDiff:max(fit(p).values); % go to the max
      xRange = unique(sort([xLow xHDIRange xHigh])); % string it all together
      [y,x] = hist(fit(p).values,xRange);
      %     end
      isHDI = x >= (hdiEdges(1)) & ...
        x <= (hdiEdges(2));
      y = y /sum(y);
      
      bHDI = bar(x(isHDI),y(isHDI));
      bHDI.EdgeColor = 'none';
      bHDI.BarWidth = .5;
      bHDI.FaceAlpha = .75;
      bHDI.FaceColor = [.1 .1 .1 ];
      %
      bOut = bar(x(~isHDI),y(~isHDI));
      bOut.EdgeColor = 'none';
      bOut.BarWidth = .5;
      bOut.FaceAlpha = .5;
      bOut.FaceColor = [.5 .5 .5 ];
      %
      ys = normpdf(x(y>0),fit(p).mu,fit(p).sig);
      ysNorm = ys ./ sum(ys);
      %     plot(x(y>0),ysNorm,'linewidth',2,'color','k')
      %
      hdiRound = [(hdiEdges(1)), (hdiEdges(2))];
      Y = ylim;
      if ~any(isnan(hdiRound))
        if ~isempty(comp)
          for c = 1:length(comp.values(p,:))
            plot(ones(1,100)*comp.values(p,c),linspace(0,1,100),'k:','linewidth',3)
            ax = gca;
            ax.YLim = [-.1*Y(2) Y(2)];
            xPos = (comp.values(p,c) - ax.XLim(1)) / diff(ax.XLim);
            if xPos > 0 && xPos < 1 % don't put the text up there if it's out of the range
              switch comp.dir(p,c) % report as greater than or less than?
                case 1
                  text(.05,.75,['Pr(\delta \geq ' roundDec(comp.values(p,c),prec) ') = ' ...
                    roundDec(1 - mean(fit(p).values <= comp.values(p,c)),2)],...
                    'Units','Normalized','Fontsize',10,'horizontalalignment','left',...
                    'backgroundcolor',[1 1 1],'FontName','Times New Roman','margin',1)
                case -1
                  text(.05,.75,['Pr(\delta \leq ' roundDec(comp.values(p,c),prec) ') = ' ...
                    roundDec(1 - mean(fit(p).values >= comp.values(p,c)),2)],...
                    'Units','Normalized','Fontsize',10,'horizontalalignment','left',...
                    'backgroundcolor',[1 1 1],'FontName','Times New Roman','margin',1)
              end
            end
          end
        end
        %
        r = rectangle('Position',[hdiRound(1) -1 hdiRound(2)-hdiRound(1) 1],...
          'FaceColor',[.5 .5 .5],'edgecolor','none');
        xNorm = (hdiRound - ax.XLim(1)) / diff(ax.XLim);
        text(xNorm(1)+.025,.135,[roundDec(hdiRound(1),prec)],'FontSize',16,'horizontalalignment','left',...
          'Color',[0 0 0],'fontweight','bold','FontName','Times New Roman','backgroundcolor',[1 1 1],'margin',.1,...
          'units','normalized','FontSize',10)
        text(xNorm(2)-.025,.135,[roundDec(hdiRound(2),prec)],'FontSize',16,'horizontalalignment','right',...
          'Color',[0 0 0],'fontweight','bold','FontName','Times New Roman','backgroundcolor',[1 1 1],'margin',.1,...
          'units','normalized','FontSize',10)
        %
        text(.05,.9,['Mode = ' roundDec(fit(p).mode,prec)],...
          'horizontalalignment','left','fontsize',10,...
          'Units','normalized','backgroundcolor',[1 1 1],...
          'FontName','Times New Roman','margin',1)
      end
    end
  end
%%
  function cols = getColors(p,n)
    % make some adjustments if there are very few items that need colors -- the edges of the cbrewer
    % scales can be hard to see, so grab values more in the middle
    if n < 5
      nn = 5;
    else
      nn = n;
    end
    
    cols = cbrewer('seq',cbrewNames{mod(p-1,length(cbrewNames))+1},nn);
    cols = cols(end:-1:1,:);
  end
%%
  function configureAxes(mode,ax,p,varargin)
    cla(ax); hold on
    ax.FontSize = 16;
    ax.FontName = 'Times New Roman';
    switch mode
      case 'chain'
        ax.ColorOrder = varargin{1};
        try; ax.XLim = [1 model.settings.n.steps - model.settings.sampling.nBurnin];end
        yMean = mean(MC.models(m).bayes.posteriors.parameters.fit(p).plotEdges);
        yDiff = diff(MC.models(m).bayes.posteriors.parameters.fit(p).plotEdges);
        if ~any(isnan(yMean + [-1.05*yDiff 1.05*yDiff]))
          ax.YLim = yMean + [-1.05*yDiff 1.05*yDiff];
        end
        if p == 1
          ax.YLabel.String = 'Parameter Value';
          ax.XLabel.String = 'Iteration';
        end
        ax.FontSize = 10;
      case 'prior'
        ax.XLim = varargin{1};
        if p == 1
          ax.YLabel.String = 'Prior Probability';
        end
        ax.FontSize = 10;
      case 'posterior'
        if ~any(isnan(MC.models(m).bayes.posteriors.parameters.fit(p).plotEdges))
          ax.XLim = MC.models(m).bayes.posteriors.parameters.fit(p).plotEdges;
        end
        if p == 1
          ax.YLabel.String = 'Posterior Probability';
        end
        ax.FontSize = 10;
      case 'pairwisePredictions'
        plotLims = norminv([.001,.999],MC.models(m).bayes.posteriors.pairwise.predict.fit(p).mu,...
          MC.models(m).bayes.posteriors.pairwise.predict.fit(p).sig);
        if ~any(isnan(plotLims))
          ax.XLim = plotLims;
        end
        if p == 1
          ax.YLabel.String = 'Posterior Density';
          ax.XLabel.String = 'Predicted Difference';
          ax.XLabel.Units = 'Normalized';
          %           ax.XLabel.Position(1) = .25;
        end
        c1 = MC.models(m).comparisons.pairwise.predictions.conditions(p,1);
        c2 = MC.models(m).comparisons.pairwise.predictions.conditions(p,2);
        ax.FontWeight = 'bold';
        tit = [MC.models(m).names.conditions{c1}, ' ', char(8722), ' ', MC.models(m).names.conditions{c2}];
        ax.Title.String = tit;
        ax.Title.FontSize = 16;
        ax.Title.Units = 'normalized';
        ax.Title.Position(2) = 1.;
      case 'pairwiseParameters'
        plotLims = norminv([.001,.999],MC.models(m).bayes.posteriors.pairwise.parameters.fit(p).mu,...
          MC.models(m).bayes.posteriors.pairwise.parameters.fit(p).sig);
        if ~any(isnan(plotLims))
          ax.XLim = plotLims;
        end
        if intersect(p,[1,7])
          ax.YLabel.String = 'Posterior Density';
          ax.XLabel.String = 'Predicted Difference';
          ax.XLabel.Units = 'Normalized';
          %           ax.XLabel.Position(1) = .25;
        end
        c1 = MC.models(m).comparisons.pairwise.parameters.comparisons(p,1);
        c2 = MC.models(m).comparisons.pairwise.parameters.comparisons(p,2);
        ax.FontWeight = 'bold';
        if ~any(isnan([c1,c2]))
          tit = [MC.models(m).names.params{c2}, ' ', char(8722), ' ', MC.models(m).names.params{c1}];
        else
          cList = [c1,c2]; cListFilt = cList(~isnan(cList));
          ind = find(cListFilt == cList);
          switch ind
            case 2
              tit = [MC.models(m).names.params{cListFilt}, ' ', char(8722), ' ', 'Chance'];
            case 1
              tit = ['Chance', ' ', char(8722), ' ', MC.models(m).names.params{cListFilt}];
          end
        end
        ax.FontSize = 12;
        ax.Title.String = tit;
        ax.Title.FontSize = 16;
        ax.Title.Units = 'normalized';
        ax.Title.Position(2) = 1.05;
        ax.Box = 'on';
    end
  end
end
