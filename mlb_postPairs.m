% model = Q.SCRIPTS(2).STATS.I.B.model;
% chain = Q.SCRIPTS(2).STATS.I.B.chain;
function mlb_postPairs(ax,p1,p2,model,chain)
% p1 = 1;
% p2 = 6;

lims1 = model.bayes.posteriors.parameters.fit(p1).HDIedges;
% lims1 = [model.settings.sampling.min(p1),model.settings.sampling.max(p1)];
range1 = linspace(lims1(1),lims1(2),100);
best1 = closest(range1,model.bayes.posteriors.parameters.fit(p1).mu);

lims2 = model.bayes.posteriors.parameters.fit(p2).HDIedges;
% lims2 = [model.settings.sampling.min(p2),model.settings.sampling.max(p2)];
range2 = linspace(lims2(1),lims2(2),100);
best2 = closest(range2,model.bayes.posteriors.parameters.fit(p2).mu);

[X,Y] = meshgrid(range1,range2);
% [X,Y] = meshgrid(-10:.1:10);

ZZ = griddata(chain.params(:,p1),...
  chain.params(:,p2),...
  chain.likelihoods(:,3),X,Y,'cubic');
% rand(size(chain.params(:,p1)))
%   chain.likelihoods(:,3),X,Y);

%%
filtXY = -3:.1:3;
filtZ = normpdf(filtXY,0,.5);
filt2 = kron(filtZ,filtZ');
filt2 = filt2 ./ sum(sum(filt2));

%%
% ZZS = filter2(ZZ,fspecial('gaussian',length(ZZ)));
ZZS = conv2(ZZ,filt2,'same');

%%
% figure(50);
if ~isempty(ZZS)
  cla(ax); hold on
  mesh(ax,ZZS)
  % imagesc(ax,ZZS)
  axis square
  cm = pmkmp;
  colormap(cm)
  
  %
  %   hold on
  scatter3(50,50,ZZS(50,50),'o','SizeData',250);
end

  function i = closest(range,val)
    d = abs(range-val);
    i = find(min(d)==d);
  end
end