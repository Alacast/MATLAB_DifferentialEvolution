function mlb_plotBayes(model,chain)
%% 

figure(202);clf
plot(chain.likelihoods)

figure(203);clf
plot(conv(chain.kept,(1/50)*ones(1,50),'valid'))

figure(201);clf
subplot(2,1,1)
plot(chain.params)
legend(model.names.params,'location','eastoutside')

subplot(2,1,2)
plot(chain.params ./ model.settings.sampling.varianceScaled)
legend(model.names.params,'location','eastoutside')

%%
mlb_showPosterior(model)

%%
mlb_plotPrediction(model,chain)

end