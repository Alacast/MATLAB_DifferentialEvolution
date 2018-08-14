function mlb_handFit(MC,modelNum)

model = MC.models(modelNum);

likes = squeeze(sum(model.predict.LLike,2));
[bestT,bestC] = find(likes == max(max(likes)),1,'first');

bestP = model.chains(bestC).params(bestT,:);

eval(['[overallLL,SIM] = ' model.function.sim '(model,bestP,MC.data);'])


MCnew.models(1) = MC.models(modelNum);
MCnew.models(1).chains = [];
MCnew.models(1).chains(1).params = bestP;
MCnew.models(1).chains(1).predict{1} = SIM;
MCnew.models(1).chains(1).logLike(1,:) = overallLL;

model.settings.n.steps = 1;
model.settings.n.chains = 1;

fig(MC.models(modelNum).plotting.figBase+20,'cf');    
eval([MC.models(modelNum).function.postPredict '(MCnew.models(modelNum),MC.data,model.settings);'])
% model.best.params = p;
% model = plot_bestIndiv(model);
% plot_accRT(model)
% keyboard
end