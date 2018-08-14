function mlb_simpleOutput(model,chain)

%%
f(1) = smh_fig(1);
subplot(2,1,1)
plot(chain.params)
subplot(2,1,2)
plot(chain.params_burn)


%%
f(2) = smh_fig(2);
subplot(2,1,1)
plot(chain.likelihoods)
subplot(2,1,2)
plot(chain.likelihoods_burn)


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ARRANGE FIGURES %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for ff = 1:2
%   f(ff).Units = 'Normalized';
%   f(ff).Position = smh_arrangeFigures(ff,1,2);
% end
%%
disp(['Model Run Time: ' num2str(model.settings.runTime) ' minutes'])
disp(['Mean Number of Accepted Steps = ' smh_roundDec(mean(chain.kept),2)])
