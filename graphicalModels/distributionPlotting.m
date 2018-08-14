% distribution plotting
F = 0;

%% GAMMA
F = F + 1;
figure(F); clf; hold on
set(1,'color',[1 1 1])

xs = 0:.01:10;
plot(xs,gampdf(xs,2,.75),'linewidth',10)
axis off
export_fig('gamma.png','-nocrop')


%% UNIF
F = F + 1;
figure(F); clf; hold on
xs = -5:55;
plot(xs,unifpdf(xs,0,50),'linewidth',10)
axis off
export_fig('unif.png','-nocrop')

%% NORMAL
F = F + 1;
figure(F); clf; hold on
xs = -5:.1:5;
plot(xs,normpdf(xs,0,1),'linewidth',10)
axis off
export_fig('norm.png','-nocrop')